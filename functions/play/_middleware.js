// Trava de acesso ao app web (/play/*) por LINK DE USO ÚNICO.
//
// Como funciona:
//  - Cada convidado tem uma chave aleatória guardada na KV (binding ACESSOS):
//        chave:<CHAVE>  ->  nome do convidado
//  - Link do convidado:  https://dungeonlog.weberlabs.com.br/play/?k=<CHAVE>
//  - Ao abrir, a chave é QUEIMADA (apagada da KV) e o navegador recebe um cookie
//    assinado (HMAC com GATE_SECRET) que vale por 1 ano. Repassar o link depois
//    não funciona: a chave já não existe mais.
//  - Sem cookie válido, /play/* volta para a página inicial.
//  - Revogar alguém: criar na KV a chave  revogado:<nome>  (qualquer valor).
//  - Ver quem já entrou: a KV ganha  usado:<nome>  com a data do primeiro acesso.
//  - Desligar a trava (lançamento na Play Store): variável PLAY_GATE = off.
//
// Se o binding ACESSOS ou a variável GATE_SECRET não estiverem configurados, a
// trava fica INATIVA (o app abre normal) e a resposta ganha o cabeçalho
// x-play-gate: inativo — de propósito, para uma configuração errada nunca
// trancar o app inteiro (nem o app da loja). Depois de configurar, confira abrindo
// /play/ numa aba anônima: tem que voltar para a página inicial.

const COOKIE = 'dl_acesso';
const UM_ANO = 60 * 60 * 24 * 365;

const enc = new TextEncoder();

async function hmac(segredo, texto) {
  const chave = await crypto.subtle.importKey('raw', enc.encode(segredo), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign('HMAC', chave, enc.encode(texto));
  return Array.from(new Uint8Array(sig)).map(b => b.toString(16).padStart(2, '0')).join('');
}

function igual(a, b) {
  if (a.length !== b.length) return false;
  let r = 0;
  for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return r === 0;
}

function lerCookie(request, nome) {
  const c = request.headers.get('Cookie') || '';
  for (const parte of c.split(';')) {
    const i = parte.indexOf('=');
    if (i > 0 && parte.slice(0, i).trim() === nome) return parte.slice(i + 1).trim();
  }
  return '';
}

// cookie = <nome-em-hex>.<hmac>
function hex(texto) { return Array.from(enc.encode(texto)).map(b => b.toString(16).padStart(2, '0')).join(''); }
function deHex(h) {
  if (!/^([0-9a-f]{2})+$/.test(h)) return '';
  const bytes = new Uint8Array(h.length / 2);
  for (let i = 0; i < bytes.length; i++) bytes[i] = parseInt(h.substr(i * 2, 2), 16);
  try { return new TextDecoder().decode(bytes); } catch (e) { return ''; }
}

async function nomeDoCookie(request, segredo) {
  const v = lerCookie(request, COOKIE);
  const ponto = v.indexOf('.');
  if (ponto < 1) return '';
  const nomeHex = v.slice(0, ponto);
  const esperado = await hmac(segredo, nomeHex);
  if (!igual(esperado, v.slice(ponto + 1))) return '';
  return deHex(nomeHex);
}

function paraInicio(url) {
  return Response.redirect(new URL('/', url).toString(), 302);
}

export async function onRequest(context) {
  const { request, env, next } = context;
  const url = new URL(request.url);

  if (env.PLAY_GATE === 'off') return next();
  if (!env.ACESSOS || !env.GATE_SECRET) {
    const r = await next();
    const resp = new Response(r.body, r);
    resp.headers.set('x-play-gate', 'inativo');
    return resp;
  }

  // 1) chegou com uma chave no link?
  const k = url.searchParams.get('k');
  if (k) {
    if (!/^[A-Za-z0-9_-]{6,64}$/.test(k)) return paraInicio(url);
    const nome = await env.ACESSOS.get('chave:' + k);
    if (!nome) return paraInicio(url); // inexistente ou já usada
    await env.ACESSOS.delete('chave:' + k); // queima a chave
    await env.ACESSOS.put('usado:' + nome, new Date().toISOString());
    const nomeHex = hex(nome);
    const valor = nomeHex + '.' + await hmac(env.GATE_SECRET, nomeHex);
    url.searchParams.delete('k'); // não deixa a chave no histórico nem no referrer
    const destino = url.pathname + (url.search || '');
    return new Response(null, {
      status: 302,
      headers: {
        'Location': destino,
        'Set-Cookie': `${COOKIE}=${valor}; Path=/play; Max-Age=${UM_ANO}; HttpOnly; Secure; SameSite=Lax`,
        'Cache-Control': 'no-store',
      },
    });
  }

  // 2) já tem cookie válido?
  const nome = await nomeDoCookie(request, env.GATE_SECRET);
  if (!nome) return paraInicio(url);

  // revogação: só consultada nas páginas (não em cada arquivo do app)
  const ehPagina = (request.headers.get('Sec-Fetch-Dest') === 'document') || (request.headers.get('Accept') || '').includes('text/html');
  if (ehPagina && await env.ACESSOS.get('revogado:' + nome)) return paraInicio(url);

  const resp = await next();
  const out = new Response(resp.body, resp);
  // o app só abre com cookie: nada de cache compartilhado (CDN/proxy), só do navegador
  const original = resp.headers.get('Cache-Control') || 'max-age=0, must-revalidate';
  const partes = original.split(',').map(p => p.trim()).filter(p => p && !/^(public|private)$/i.test(p));
  out.headers.set('Cache-Control', ['private'].concat(partes).join(', '));
  return out;
}
