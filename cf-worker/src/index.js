/* =============================================================================
   DungeonLog -- notificacoes push, versao Cloudflare Worker (SEM Firebase
   Cloud Functions -- pedido do usuario: zero gasto, e Cloud Functions so
   roda no plano Blaze do Firebase, que exige cartao cadastrado).

   Cloudflare Workers no plano gratuito ja inclui Cron Triggers (ate 3 por
   Worker) sem pedir cartao -- e a conta ja existe, e' a mesma que hospeda
   o app (Cloudflare Pages). Esse Worker faz exatamente o que as 2 Cloud
   Functions descartadas fariam, so que chamando a API REST do Firestore e
   a API HTTP v1 do FCM diretamente, autenticado como uma Service Account
   do Firebase (gerar uma NAO precisa de Blaze -- e' so uma credencial de
   IAM do projeto, disponivel em qualquer plano).

   Nenhuma dependencia externa (sem npm install, sem build step) -- so usa
   fetch() e Web Crypto (crypto.subtle), ja nativos no runtime do Worker.
   Isso e' de proposito: menos superficie, deploy com um `wrangler deploy`
   direto.

   Ver README.md nesta mesma pasta pro passo a passo de deploy (gerar a
   service account, configurar o secret, `wrangler deploy`).
   ============================================================================= */

const FIRESTORE_BASE = 'https://firestore.googleapis.com/v1';
const FCM_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
const FIRESTORE_SCOPE = 'https://www.googleapis.com/auth/datastore';

// -----------------------------------------------------------------------
// AUTENTICACAO -- troca a Service Account por um access token OAuth2 via
// JWT assinado (RS256, Web Crypto). Mesmo fluxo que o Admin SDK faz por
// baixo dos panos, so que reimplementado a mao porque o Admin SDK
// (pacote npm firebase-admin) nao roda no runtime do Workers.
// -----------------------------------------------------------------------

function base64UrlDeBytes(bytes){
  let bin = '';
  bytes.forEach(b => { bin += String.fromCharCode(b); });
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function base64UrlDeString(str){
  return base64UrlDeBytes(new TextEncoder().encode(str));
}

// PEM -> ArrayBuffer (remove cabecalho/rodape "-----BEGIN/END PRIVATE
// KEY-----" e as quebras de linha, decodifica o base64 que sobra).
function pemParaArrayBuffer(pem){
  const corpo = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const bin = atob(corpo);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes.buffer;
}

async function assinarJWT(serviceAccount, escopo){
  const agora = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claims = {
    iss: serviceAccount.client_email,
    scope: escopo,
    aud: 'https://oauth2.googleapis.com/token',
    iat: agora,
    exp: agora + 3600,
  };
  const semAssinar = base64UrlDeString(JSON.stringify(header)) + '.' + base64UrlDeString(JSON.stringify(claims));

  const chave = await crypto.subtle.importKey(
    'pkcs8',
    pemParaArrayBuffer(serviceAccount.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const assinatura = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', chave, new TextEncoder().encode(semAssinar));
  return semAssinar + '.' + base64UrlDeBytes(new Uint8Array(assinatura));
}

async function obterAccessToken(serviceAccount, escopo){
  const jwt = await assinarJWT(serviceAccount, escopo);
  const resp = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'grant_type=' + encodeURIComponent('urn:ietf:params:oauth:grant-type:jwt-bearer') + '&assertion=' + encodeURIComponent(jwt),
  });
  if (!resp.ok) throw new Error('OAuth2 token falhou: ' + resp.status + ' ' + (await resp.text()));
  const dados = await resp.json();
  return dados.access_token;
}

// -----------------------------------------------------------------------
// FIRESTORE REST -- os documentos vem com valores "tipados"
// ({stringValue:...}/{integerValue:...}/{mapValue:{fields:{...}}}/
// {arrayValue:{values:[...]}}), bem diferente do JSON puro que o SDK
// modular do client usa. fsParaJs()/jsParaFs() convertem nos dois
// sentidos so pro que este Worker realmente precisa ler/escrever (nao e'
// um conversor genérico completo -- cobre string/number/array de string/
// mapa, que e' tudo que os docs `saves`/`fcmTokens`/`notifEnviadas` usam).
// -----------------------------------------------------------------------

function fsParaJs(valor){
  if (valor == null) return null;
  if ('stringValue' in valor) return valor.stringValue;
  if ('integerValue' in valor) return Number(valor.integerValue);
  if ('doubleValue' in valor) return valor.doubleValue;
  if ('booleanValue' in valor) return valor.booleanValue;
  if ('nullValue' in valor) return null;
  if ('arrayValue' in valor) return (valor.arrayValue.values || []).map(fsParaJs);
  if ('mapValue' in valor) return fsFieldsParaObjeto(valor.mapValue.fields || {});
  return null;
}

function fsFieldsParaObjeto(fields){
  const obj = {};
  Object.keys(fields).forEach(k => { obj[k] = fsParaJs(fields[k]); });
  return obj;
}

function jsParaFs(valor){
  if (typeof valor === 'string') return { stringValue: valor };
  if (typeof valor === 'number') return Number.isInteger(valor) ? { integerValue: String(valor) } : { doubleValue: valor };
  if (typeof valor === 'boolean') return { booleanValue: valor };
  if (Array.isArray(valor)) return { arrayValue: { values: valor.map(jsParaFs) } };
  if (valor && typeof valor === 'object') return { mapValue: { fields: objetoParaFsFields(valor) } };
  return { nullValue: null };
}

function objetoParaFsFields(obj){
  const fields = {};
  Object.keys(obj).forEach(k => { fields[k] = jsParaFs(obj[k]); });
  return fields;
}

async function firestoreGetDoc(projectId, accessToken, caminho){
  const resp = await fetch(FIRESTORE_BASE + '/projects/' + projectId + '/databases/(default)/documents/' + caminho, {
    headers: { Authorization: 'Bearer ' + accessToken },
  });
  if (resp.status === 404) return null;
  if (!resp.ok) throw new Error('Firestore GET ' + caminho + ' falhou: ' + resp.status + ' ' + (await resp.text()));
  const doc = await resp.json();
  return fsFieldsParaObjeto(doc.fields || {});
}

// Lista uma colecao inteira, paginando sozinho (a API REST devolve no
// maximo `pageSize` documentos por chamada + um nextPageToken). Retorna
// [{id, dados}], onde `id` e' o ultimo segmento do nome do documento
// (o uid, no caso de fcmTokens/saves/notifEnviadas).
async function firestoreListarColecao(projectId, accessToken, colecao){
  const itens = [];
  let pageToken = null;
  do {
    const url = new URL(FIRESTORE_BASE + '/projects/' + projectId + '/databases/(default)/documents/' + colecao);
    url.searchParams.set('pageSize', '300');
    if (pageToken) url.searchParams.set('pageToken', pageToken);
    const resp = await fetch(url.toString(), { headers: { Authorization: 'Bearer ' + accessToken } });
    if (!resp.ok) throw new Error('Firestore LIST ' + colecao + ' falhou: ' + resp.status + ' ' + (await resp.text()));
    const pagina = await resp.json();
    (pagina.documents || []).forEach(doc => {
      const id = doc.name.split('/').pop();
      itens.push({ id, dados: fsFieldsParaObjeto(doc.fields || {}) });
    });
    pageToken = pagina.nextPageToken || null;
  } while (pageToken);
  return itens;
}

// PATCH so nos campos passados (updateMask) -- cria o doc se nao existir,
// nunca mexe em campos que nao estao em `camposParciais`. Equivalente ao
// admin.firestore().doc(caminho).set(camposParciais, {merge:true}).
async function firestorePatchParcial(projectId, accessToken, caminho, camposParciais){
  const chaves = Object.keys(camposParciais);
  const url = new URL(FIRESTORE_BASE + '/projects/' + projectId + '/databases/(default)/documents/' + caminho);
  chaves.forEach(k => url.searchParams.append('updateMask.fieldPaths', k));
  const resp = await fetch(url.toString(), {
    method: 'PATCH',
    headers: { Authorization: 'Bearer ' + accessToken, 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields: objetoParaFsFields(camposParciais) }),
  });
  if (!resp.ok) throw new Error('Firestore PATCH ' + caminho + ' falhou: ' + resp.status + ' ' + (await resp.text()));
}

// -----------------------------------------------------------------------
// FCM HTTP v1 -- diferente da Admin SDK (sendEachForMulticast, 1 chamada
// pra varios tokens), a API REST v1 manda 1 token por chamada. Devolve se
// deu certo e se o token deveria ser removido (invalido/desregistrado).
// -----------------------------------------------------------------------

async function enviarFcm(projectId, accessToken, token, dados){
  const resp = await fetch('https://fcm.googleapis.com/v1/projects/' + projectId + '/messages:send', {
    method: 'POST',
    headers: { Authorization: 'Bearer ' + accessToken, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      message: {
        token,
        data: dados, // so `data`, de proposito -- ver onBackgroundMessage() em play/firebase-messaging-sw.js
        webpush: { fcm_options: { link: 'https://dungeonlog.weberlabs.com.br/play/' } },
      },
    }),
  });
  if (resp.ok) return { ok: true };
  const corpo = await resp.json().catch(() => null);
  const status = corpo && corpo.error && corpo.error.status;
  const invalido = status === 'NOT_FOUND' || status === 'UNREGISTERED' || status === 'INVALID_ARGUMENT';
  return { ok: false, invalido };
}

// Manda pra todos os tokens de uma conta e devolve a lista de tokens que
// ainda sao validos (pra sobrescrever fcmTokens/{uid}.tokens sem lixo).
async function enviarParaConta(projectId, accessToken, tokens, dados){
  const validos = [];
  let algumEnviado = false;
  for (const token of tokens){
    const resultado = await enviarFcm(projectId, accessToken, token, dados);
    if (resultado.ok){
      algumEnviado = true;
      validos.push(token);
    } else if (!resultado.invalido){
      validos.push(token); // erro passageiro (rede, quota) -- mantem o token, tenta de novo amanha
    }
    // invalido === true -> nao entra em `validos`, remove de vez
  }
  return { algumEnviado, validos };
}

// -----------------------------------------------------------------------
// DATAS / STREAK -- mesma logica de isoAtual()/estStreakAtual()
// (play/index.html) -- reimplementada aqui porque este Worker nao
// compartilha codigo nenhum com o app. Mudou la, muda aqui tambem.
// -----------------------------------------------------------------------

const FUSO = 'America/Sao_Paulo';

function hojeSP(){
  const partes = new Intl.DateTimeFormat('en-CA', {
    timeZone: FUSO, year: 'numeric', month: '2-digit', day: '2-digit',
  }).formatToParts(new Date());
  const mapa = {};
  partes.forEach(p => { mapa[p.type] = p.value; });
  return mapa.year + '-' + mapa.month + '-' + mapa.day;
}

function diaAnterior(iso){
  const d = new Date(iso + 'T12:00:00Z');
  d.setUTCDate(d.getUTCDate() - 1);
  return d.toISOString().slice(0, 10);
}

function calcularStreak(hist, hojeIso){
  const porData = new Map(hist.map(h => [h.data, h.resultado]));
  let cursor = hojeIso;
  if (!porData.has(cursor)) cursor = diaAnterior(cursor);
  let streak = 0;
  while (porData.get(cursor) === 'vitoria'){
    streak++;
    cursor = diaAnterior(cursor);
  }
  return streak;
}

function lerExtra(extras, chave){
  if (!extras || typeof extras[chave] !== 'string') return null;
  try { return JSON.parse(extras[chave]); } catch(e){ return null; }
}

// -----------------------------------------------------------------------
// AS 2 CHECAGENS -- mesma logica que estava em functions/index.js
// (Cloud Functions descartadas), so trocando Admin SDK por chamadas REST.
// -----------------------------------------------------------------------

async function checarTesteGratisAcabando(env){
  const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT);
  const projectId = serviceAccount.project_id;
  const tokenFirestore = await obterAccessToken(serviceAccount, FIRESTORE_SCOPE);
  const tokenFcm = await obterAccessToken(serviceAccount, FCM_SCOPE);
  const hoje = hojeSP();

  const contas = await firestoreListarColecao(projectId, tokenFirestore, 'fcmTokens');

  for (const conta of contas){
    const uid = conta.id;
    const tokens = conta.dados.tokens || [];
    if (!tokens.length) continue;

    const save = await firestoreGetDoc(projectId, tokenFirestore, 'saves/' + uid);
    if (!save) continue;

    const trial = lerExtra(save.extras, 'questlog.trial.v1');
    if (!trial || typeof trial.fim !== 'number') continue;
    if (Date.now() >= trial.fim) continue;

    const diasRestantes = Math.max(0, Math.ceil((trial.fim - Date.now()) / 86400000));
    if (diasRestantes > trial.avisoDias) continue;

    const status = await firestoreGetDoc(projectId, tokenFirestore, 'notifEnviadas/' + uid);
    if (status && status.trialDia === hoje) continue;

    const corpo = diasRestantes <= 0
      ? 'Seu teste grátis acaba hoje! Assine pra não perder o Plano Pro.'
      : ('Seu teste grátis acaba em ' + diasRestantes + (diasRestantes === 1 ? ' dia! ' : ' dias! ') + 'Assine pra não perder o Plano Pro.');

    const resultado = await enviarParaConta(projectId, tokenFcm, tokens, {
      titulo: 'Teste grátis acabando',
      corpo,
      tipo: 'trial',
    });
    if (resultado.validos.length !== tokens.length){
      await firestorePatchParcial(projectId, tokenFirestore, 'fcmTokens/' + uid, { tokens: resultado.validos });
    }
    if (resultado.algumEnviado){
      await firestorePatchParcial(projectId, tokenFirestore, 'notifEnviadas/' + uid, { trialDia: hoje });
    }
  }
}

async function checarFimDeDia(env){
  const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT);
  const projectId = serviceAccount.project_id;
  const tokenFirestore = await obterAccessToken(serviceAccount, FIRESTORE_SCOPE);
  const tokenFcm = await obterAccessToken(serviceAccount, FCM_SCOPE);
  const hoje = hojeSP();

  const contas = await firestoreListarColecao(projectId, tokenFirestore, 'fcmTokens');

  for (const conta of contas){
    const uid = conta.id;
    const tokens = conta.dados.tokens || [];
    if (!tokens.length) continue;

    const save = await firestoreGetDoc(projectId, tokenFirestore, 'saves/' + uid);
    if (!save) continue;

    const hp = lerExtra(save.extras, 'questlog.hpMonstro.v1');
    if (!hp || hp.dia !== hoje) continue;
    const viva = Math.max(0, (hp.total || 0) - (hp.dano || 0));
    if (viva <= 0) continue;

    const status = await firestoreGetDoc(projectId, tokenFirestore, 'notifEnviadas/' + uid);
    if (status && status.fimDiaDia === hoje) continue;

    const hist = lerExtra(save.extras, 'questlog.hist.v1') || [];
    const streak = calcularStreak(hist, hoje);

    const corpo = streak > 0
      ? ('Sua sequência de ' + streak + (streak === 1 ? ' dia' : ' dias') + ' corre risco! O monstro de hoje ainda tem ' + viva + ' de vida.')
      : ('Você ainda tem tarefas pendentes hoje -- o monstro tem ' + viva + ' de vida restante.');

    const resultado = await enviarParaConta(projectId, tokenFcm, tokens, {
      titulo: streak > 0 ? 'Sua sequência corre risco!' : 'Tarefas pendentes hoje',
      corpo,
      tipo: 'fimDeDia',
    });
    if (resultado.validos.length !== tokens.length){
      await firestorePatchParcial(projectId, tokenFirestore, 'fcmTokens/' + uid, { tokens: resultado.validos });
    }
    if (resultado.algumEnviado){
      await firestorePatchParcial(projectId, tokenFirestore, 'notifEnviadas/' + uid, { fimDiaDia: hoje });
    }
  }
}

export default {
  async scheduled(event, env, ctx){
    if (event.cron === '0 13 * * *'){
      ctx.waitUntil(checarTesteGratisAcabando(env).catch(e => console.error('checarTesteGratisAcabando falhou', e)));
    } else if (event.cron === '0 23 * * *'){
      ctx.waitUntil(checarFimDeDia(env).catch(e => console.error('checarFimDeDia falhou', e)));
    }
  },

  // GET manual (visitar a URL do Worker) so pra facilitar teste sem
  // esperar o cron -- roda as 2 checagens na hora. Nao e' um endpoint
  // publico de verdade (ninguem alem de quem sabe a URL do Worker acessa
  // isso, e nao expoe nenhum dado, so dispara os envios) mas se quiser
  // travar de vez depois de testar, e' so apagar este handler `fetch`.
  async fetch(request, env, ctx){
    await Promise.all([checarTesteGratisAcabando(env), checarFimDeDia(env)]);
    return new Response('OK -- checagens rodadas manualmente\n');
  },
};
