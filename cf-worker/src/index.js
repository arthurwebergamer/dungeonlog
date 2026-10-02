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

// LIMITE REAL a ter em mente: o plano gratuito do Workers permite so 50
// subrequests (fetch() feitos DE DENTRO do Worker) POR EXECUCAO. Se este
// Worker fizesse 1 GET (saves) + 1 GET (notifEnviadas) POR CONTA, uma
// base de so ~10 contas com push ativo ja estouraria o limite. Por isso
// firestoreBatchGetDocs()/firestoreCommitLote() abaixo existem -- pegam
// VARIOS documentos numa unica chamada (ate 100 por vez aqui, a API real
// aceita mais, 100 e' so uma margem confortavel), transformando "1
// subrequest por conta" em "1 subrequest a cada 100 contas". Com isso, o
// numero de contas que cabe numa execucao passa a ser limitado pelos
// ENVIOS de push de verdade (1 subrequest por token, sem como agrupar --
// a API REST v1 do FCM nao tem multicast), no' pelas leituras/escritas no
// Firestore. Ver README.md, secao "Limites", pras contas completas.
async function firestoreBatchGetDocs(projectId, accessToken, caminhos){
  const porCaminho = new Map(); // 'colecao/uid' -> dados (ou undefined se o doc nao existe)
  const TAMANHO_LOTE = 100;
  for (let i = 0; i < caminhos.length; i += TAMANHO_LOTE){
    const lote = caminhos.slice(i, i + TAMANHO_LOTE);
    const resp = await fetch(FIRESTORE_BASE + '/projects/' + projectId + '/databases/(default)/documents:batchGet', {
      method: 'POST',
      headers: { Authorization: 'Bearer ' + accessToken, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        documents: lote.map(c => 'projects/' + projectId + '/databases/(default)/documents/' + c),
      }),
    });
    if (!resp.ok) throw new Error('Firestore batchGet falhou: ' + resp.status + ' ' + (await resp.text()));
    const itens = await resp.json(); // array de BatchGetDocumentsResponse, 1 por documento pedido
    itens.forEach(item => {
      if (!item.found) return; // doc nao existe -- fica de fora do Map, .get() devolve undefined
      const relativo = item.found.name.split('/documents/')[1]; // 'projects/.../documents/saves/uid123' -> 'saves/uid123'
      porCaminho.set(relativo, fsFieldsParaObjeto(item.found.fields || {}));
    });
  }
  return porCaminho;
}

// Varias escritas parciais (equivalente a set(...,{merge:true}) em cada
// uma) numa UNICA chamada -- em vez de 1 PATCH por conta que precisa
// atualizar notifEnviadas/fcmTokens, todas viram 1 subrequest so (ou
// poucas, se passar de 500 escritas, limite real do commit da API).
function escritaParcial(projectId, caminho, camposParciais){
  return {
    update: { name: 'projects/' + projectId + '/databases/(default)/documents/' + caminho, fields: objetoParaFsFields(camposParciais) },
    updateMask: { fieldPaths: Object.keys(camposParciais) },
  };
}
async function firestoreCommitLote(projectId, accessToken, escritas){
  if (!escritas.length) return;
  const TAMANHO_LOTE = 500;
  for (let i = 0; i < escritas.length; i += TAMANHO_LOTE){
    const lote = escritas.slice(i, i + TAMANHO_LOTE);
    const resp = await fetch(FIRESTORE_BASE + '/projects/' + projectId + '/databases/(default)/documents:commit', {
      method: 'POST',
      headers: { Authorization: 'Bearer ' + accessToken, 'Content-Type': 'application/json' },
      body: JSON.stringify({ writes: lote }),
    });
    if (!resp.ok) throw new Error('Firestore commit falhou: ' + resp.status + ' ' + (await resp.text()));
  }
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

  const contas = (await firestoreListarColecao(projectId, tokenFirestore, 'fcmTokens'))
    .filter(c => (c.dados.tokens || []).length); // descarta contas sem nenhum token de cara

  // 2 chamadas em lote (nao 1 por conta) -- ver comentario em
  // firestoreBatchGetDocs() sobre o limite de 50 subrequests/execucao.
  const saves = await firestoreBatchGetDocs(projectId, tokenFirestore, contas.map(c => 'saves/' + c.id));
  const statusDocs = await firestoreBatchGetDocs(projectId, tokenFirestore, contas.map(c => 'notifEnviadas/' + c.id));

  const escritas = [];
  for (const conta of contas){
    const uid = conta.id;
    const tokens = conta.dados.tokens;

    const save = saves.get('saves/' + uid);
    if (!save) continue;

    const trial = lerExtra(save.extras, 'questlog.trial.v1');
    if (!trial || typeof trial.fim !== 'number') continue;
    if (Date.now() >= trial.fim) continue;

    const diasRestantes = Math.max(0, Math.ceil((trial.fim - Date.now()) / 86400000));
    if (diasRestantes > trial.avisoDias) continue;

    const status = statusDocs.get('notifEnviadas/' + uid);
    if (status && status.trialDia === hoje) continue;

    const corpo = diasRestantes <= 0
      ? 'Seu teste grátis acaba hoje! Assine pra não perder o Plano Pro.'
      : ('Seu teste grátis acaba em ' + diasRestantes + (diasRestantes === 1 ? ' dia! ' : ' dias! ') + 'Assine pra não perder o Plano Pro.');

    // unico ponto que ainda custa 1 subrequest POR CONTA (por token, na
    // verdade) -- a API REST v1 do FCM nao agrupa varios tokens numa
    // chamada so. E' o que de fato limita quantas contas cabem numa
    // execucao, ver README.md.
    const resultado = await enviarParaConta(projectId, tokenFcm, tokens, {
      titulo: 'Teste grátis acabando',
      corpo,
      tipo: 'trial',
    });
    if (resultado.validos.length !== tokens.length){
      escritas.push(escritaParcial(projectId, 'fcmTokens/' + uid, { tokens: resultado.validos }));
    }
    if (resultado.algumEnviado){
      escritas.push(escritaParcial(projectId, 'notifEnviadas/' + uid, { trialDia: hoje }));
    }
  }
  await firestoreCommitLote(projectId, tokenFirestore, escritas);
}

async function checarFimDeDia(env){
  const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT);
  const projectId = serviceAccount.project_id;
  const tokenFirestore = await obterAccessToken(serviceAccount, FIRESTORE_SCOPE);
  const tokenFcm = await obterAccessToken(serviceAccount, FCM_SCOPE);
  const hoje = hojeSP();

  const contas = (await firestoreListarColecao(projectId, tokenFirestore, 'fcmTokens'))
    .filter(c => (c.dados.tokens || []).length);

  const saves = await firestoreBatchGetDocs(projectId, tokenFirestore, contas.map(c => 'saves/' + c.id));
  const statusDocs = await firestoreBatchGetDocs(projectId, tokenFirestore, contas.map(c => 'notifEnviadas/' + c.id));

  const escritas = [];
  for (const conta of contas){
    const uid = conta.id;
    const tokens = conta.dados.tokens;

    const save = saves.get('saves/' + uid);
    if (!save) continue;

    // hp.dia precisa ser HOJE -- sincronizar() (play/index.html, modulo
    // VIDA DO MONSTRO) so atualiza esse registro no BOOT do app. Se a
    // conta nao abriu o app hoje, o registro e' de um dia anterior e nao
    // reflete o estado real agora.
    const hp = lerExtra(save.extras, 'questlog.hpMonstro.v1');
    if (!hp || hp.dia !== hoje) continue;
    const viva = Math.max(0, (hp.total || 0) - (hp.dano || 0));
    if (viva <= 0) continue;

    const status = statusDocs.get('notifEnviadas/' + uid);
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
      escritas.push(escritaParcial(projectId, 'fcmTokens/' + uid, { tokens: resultado.validos }));
    }
    if (resultado.algumEnviado){
      escritas.push(escritaParcial(projectId, 'notifEnviadas/' + uid, { fimDiaDia: hoje }));
    }
  }
  await firestoreCommitLote(projectId, tokenFirestore, escritas);
}

// =============================================================================
// GOOGLE PLAY BILLING -- POST /billing/verify
//
// O app (TWA) paga pela Digital Goods API e manda pra ca o purchaseToken +
// o ID token do Firebase de quem esta logado. Este endpoint:
//   1. confere o ID token (assinatura RS256 contra as chaves publicas do
//      Firebase, aud/iss/exp) -> descobre o uid. NUNCA confia no uid que o
//      client "diz" ser;
//   2. consulta a compra na Google Play Developer API (so o servidor
//      consegue, com a service account) e confere o produto e o estado;
//   3. CONFIRMA (acknowledge) a compra -- sem isso a Google estorna em 3 dias;
//   4. amarra o token a esse uid (playPurchases/{sha256}) pra a mesma compra
//      nao liberar PRO em varias contas;
//   5. grava em entitlements/{uid}: assinaturaAte (ms) p/ mensal/anual, ou
//      proVitalicio=true p/ o produto unico. O client so le (firestore.rules).
//
// Renovacoes: o app revalida (listPurchases -> este endpoint) a cada login,
// no maximo 1x/6h, e a Google devolve a nova data de validade. Cancelamento
// e estorno em tempo real dependem de RTDN (PR seguinte) -- por ora o
// cancelamento vale ate o fim do periodo ja pago (comportamento normal).
// =============================================================================

const PLAY_PACKAGE = 'com.dungeonlog';
const PLAY_SCOPE = 'https://www.googleapis.com/auth/androidpublisher';
const PLAY_BASE = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/' + PLAY_PACKAGE;
const BILLING_SKUS_ASSINATURA = ['pro_mensal', 'pro_anual'];
const BILLING_SKUS_UNICO = ['pro_vitalicio'];
const BILLING_ORIGENS = ['https://dungeonlog.weberlabs.com.br'];
const FIREBASE_JWK_URL = 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
const ESTADOS_COM_ACESSO = ['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD', 'SUBSCRIPTION_STATE_CANCELED'];

function base64UrlParaBytes(str){
  const b64 = str.replace(/-/g, '+').replace(/_/g, '/') + '==='.slice((str.length + 3) % 4);
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

let _jwkCache = { chaves: null, ate: 0 };
async function chavesFirebase(){
  if (_jwkCache.chaves && Date.now() < _jwkCache.ate) return _jwkCache.chaves;
  const resp = await fetch(FIREBASE_JWK_URL);
  if (!resp.ok) throw new Error('JWK do Firebase indisponivel: ' + resp.status);
  const dados = await resp.json();
  _jwkCache = { chaves: dados.keys || [], ate: Date.now() + 3600 * 1000 };
  return _jwkCache.chaves;
}

// Retorna o uid se o ID token do Firebase for valido; lanca erro se nao.
async function verificarIdTokenFirebase(idToken, projectId){
  const partes = String(idToken || '').split('.');
  if (partes.length !== 3) throw new Error('token malformado');
  const header = JSON.parse(new TextDecoder().decode(base64UrlParaBytes(partes[0])));
  const claims = JSON.parse(new TextDecoder().decode(base64UrlParaBytes(partes[1])));
  if (header.alg !== 'RS256' || !header.kid) throw new Error('alg invalido');
  const jwk = (await chavesFirebase()).find(k => k.kid === header.kid);
  if (!jwk) throw new Error('kid desconhecido');
  const chave = await crypto.subtle.importKey('jwk', jwk, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']);
  const ok = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5', chave, base64UrlParaBytes(partes[2]), new TextEncoder().encode(partes[0] + '.' + partes[1])
  );
  if (!ok) throw new Error('assinatura invalida');
  const agora = Math.floor(Date.now() / 1000);
  if (claims.aud !== projectId) throw new Error('aud invalido');
  if (claims.iss !== 'https://securetoken.google.com/' + projectId) throw new Error('iss invalido');
  if (typeof claims.exp !== 'number' || claims.exp <= agora) throw new Error('token expirado');
  if (typeof claims.iat !== 'number' || claims.iat > agora + 60) throw new Error('iat no futuro');
  if (!claims.sub || typeof claims.sub !== 'string') throw new Error('sem sub');
  return claims.sub;
}

async function sha256Hex(texto){
  const h = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(texto));
  return Array.from(new Uint8Array(h)).map(b => b.toString(16).padStart(2, '0')).join('');
}

async function playGet(accessToken, caminho){
  const resp = await fetch(PLAY_BASE + caminho, { headers: { Authorization: 'Bearer ' + accessToken } });
  if (!resp.ok) throw new Error('Play API ' + resp.status + ': ' + (await resp.text()).slice(0, 200));
  return resp.json();
}
async function playAcknowledge(accessToken, caminho){
  const resp = await fetch(PLAY_BASE + caminho + ':acknowledge', {
    method: 'POST',
    headers: { Authorization: 'Bearer ' + accessToken, 'Content-Type': 'application/json' },
    body: '{}',
  });
  // 400 "already acknowledged" nao e' falha de verdade
  if (!resp.ok && resp.status !== 400) throw new Error('acknowledge falhou: ' + resp.status);
}

async function firestoreLerDoc(projectId, accessToken, caminho){
  const resp = await fetch(FIRESTORE_BASE + '/projects/' + projectId + '/databases/(default)/documents/' + caminho, {
    headers: { Authorization: 'Bearer ' + accessToken },
  });
  if (resp.status === 404) return null;
  if (!resp.ok) throw new Error('Firestore get falhou: ' + resp.status);
  const doc = await resp.json();
  return fsFieldsParaObjeto(doc.fields || {});
}

function respostaJson(corpo, status, origem){
  const headers = { 'Content-Type': 'application/json' };
  if (origem && BILLING_ORIGENS.indexOf(origem) !== -1){
    headers['Access-Control-Allow-Origin'] = origem;
    headers['Vary'] = 'Origin';
  }
  return new Response(JSON.stringify(corpo), { status: status, headers: headers });
}

async function tratarBillingVerify(request, env){
  const origem = request.headers.get('Origin');
  if (request.method === 'OPTIONS'){
    const headers = {
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400',
    };
    if (origem && BILLING_ORIGENS.indexOf(origem) !== -1){ headers['Access-Control-Allow-Origin'] = origem; headers['Vary'] = 'Origin'; }
    return new Response(null, { status: 204, headers: headers });
  }
  if (request.method !== 'POST') return respostaJson({ ok: false, erro: 'metodo' }, 405, origem);

  const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT);
  const projectId = serviceAccount.project_id;

  let corpo;
  try { corpo = await request.json(); } catch(e){ return respostaJson({ ok: false, erro: 'json' }, 400, origem); }
  const sku = corpo && corpo.sku;
  const purchaseToken = corpo && corpo.purchaseToken;
  const ehAssinatura = BILLING_SKUS_ASSINATURA.indexOf(sku) !== -1;
  const ehUnico = BILLING_SKUS_UNICO.indexOf(sku) !== -1;
  if ((!ehAssinatura && !ehUnico) || typeof purchaseToken !== 'string' || purchaseToken.length < 10 || purchaseToken.length > 1000){
    return respostaJson({ ok: false, erro: 'parametros' }, 400, origem);
  }

  let uid;
  try {
    const auth = request.headers.get('Authorization') || '';
    uid = await verificarIdTokenFirebase(auth.replace(/^Bearer\s+/i, ''), projectId);
  } catch(e){
    return respostaJson({ ok: false, erro: 'nao-autenticado' }, 401, origem);
  }

  try {
    const playSa = env.PLAY_SERVICE_ACCOUNT ? JSON.parse(env.PLAY_SERVICE_ACCOUNT) : serviceAccount;
    const tokenPlay = await obterAccessToken(playSa, PLAY_SCOPE);
    const tokenFirestore = await obterAccessToken(serviceAccount, FIRESTORE_SCOPE);
    const tokenEnc = encodeURIComponent(purchaseToken);

    // 1) Valida na Google e descobre ate quando vale
    let campos;
    if (ehAssinatura){
      const compra = await playGet(tokenPlay, '/purchases/subscriptionsv2/tokens/' + tokenEnc);
      const item = (compra.lineItems || []).find(li => li.productId === sku);
      if (!item) return respostaJson({ ok: false, erro: 'produto-diferente' }, 400, origem);
      if (ESTADOS_COM_ACESSO.indexOf(compra.subscriptionState) === -1 && compra.subscriptionState !== 'SUBSCRIPTION_STATE_EXPIRED'){
        return respostaJson({ ok: false, erro: 'estado-' + compra.subscriptionState }, 402, origem);
      }
      const ate = Date.parse(item.expiryTime) || 0;
      campos = {
        assinaturaAte: ESTADOS_COM_ACESSO.indexOf(compra.subscriptionState) !== -1 ? ate : 0,
        assinaturaProduto: sku,
        assinaturaEstado: compra.subscriptionState,
      };
      // 2) token amarrado a um uid so
      const hash = await sha256Hex(purchaseToken);
      const dono = await firestoreLerDoc(projectId, tokenFirestore, 'playPurchases/' + hash);
      if (dono && dono.uid && dono.uid !== uid) return respostaJson({ ok: false, erro: 'compra-de-outra-conta' }, 409, origem);
      // 3) acknowledge (pendente -> confirmada)
      if (compra.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING' && campos.assinaturaAte > 0){
        await playAcknowledge(tokenPlay, '/purchases/subscriptions/' + encodeURIComponent(sku) + '/tokens/' + tokenEnc);
      }
      await firestoreCommitLote(projectId, tokenFirestore, [
        escritaParcial(projectId, 'playPurchases/' + hash, { uid: uid, sku: sku, atualizadoEm: Date.now() }),
        escritaParcial(projectId, 'entitlements/' + uid, campos),
      ]);
      return respostaJson({ ok: true, ate: campos.assinaturaAte }, 200, origem);
    }

    // produto unico (vitalicio)
    const compra = await playGet(tokenPlay, '/purchases/products/' + encodeURIComponent(sku) + '/tokens/' + tokenEnc);
    if (compra.purchaseState !== 0) return respostaJson({ ok: false, erro: 'nao-comprado' }, 402, origem);
    const hash = await sha256Hex(purchaseToken);
    const dono = await firestoreLerDoc(projectId, tokenFirestore, 'playPurchases/' + hash);
    if (dono && dono.uid && dono.uid !== uid) return respostaJson({ ok: false, erro: 'compra-de-outra-conta' }, 409, origem);
    if (compra.acknowledgementState === 0){
      await playAcknowledge(tokenPlay, '/purchases/products/' + encodeURIComponent(sku) + '/tokens/' + tokenEnc);
    }
    await firestoreCommitLote(projectId, tokenFirestore, [
      escritaParcial(projectId, 'playPurchases/' + hash, { uid: uid, sku: sku, atualizadoEm: Date.now() }),
      escritaParcial(projectId, 'entitlements/' + uid, { proVitalicio: true, proVitalicioPlay: true }),
    ]);
    return respostaJson({ ok: true, vitalicio: true }, 200, origem);
  } catch(e){
    console.error('billing/verify falhou', e && e.message);
    return respostaJson({ ok: false, erro: 'servidor' }, 502, origem);
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
    if (new URL(request.url).pathname === '/billing/verify') return tratarBillingVerify(request, env);
    // GET manual travado: antes qualquer pessoa com a URL disparava as checagens.
    return new Response('Not found', { status: 404 });
  },
};
