/* =========================================================================
   Service Worker do Firebase Cloud Messaging (push de verdade, chega com o
   app fechado). Pedido do usuario: notificacoes reais pra teste gratis
   acabando, streak em risco e monstro do dia ainda vivo -- ver Cloud
   Functions em /functions (raiz do repo) pra quem manda essas 3, e o
   bloco JS "MODULO NOTIFICACOES PUSH" em play/index.html pra quem pede
   permissao/token no cliente.

   Precisa ficar em /play/ (mesma pasta do app, nao na raiz do dominio) --
   o escopo de um Service Worker e' o diretorio onde o arquivo mora, e o
   app inteiro vive sob /play/ (raiz do dominio redireciona pra /waitlist,
   ver _redirects). Registrado em index.html via
   navigator.serviceWorker.register('firebase-messaging-sw.js') (caminho
   relativo -- resolve pra /play/firebase-messaging-sw.js sozinho).

   IMPORTANTE: precisa ser JS classico (importScripts), nao type=module --
   Service Workers de push ainda tem suporte inconsistente a modulos ES
   entre navegadores. Usa o SDK "compat" do Firebase (mesma versao
   10.13.2 usada no resto do app) de proposito, e' o unico jeito
   documentado de rodar o Messaging dentro de um Service Worker.

   mesmo firebaseConfig do bloco "FIREBASE AUTH" em index.html -- nao e'
   segredo (toda apiKey de app web e' publica por natureza, a seguranca
   real mora nas regras do Firestore/Auth, nao aqui), so precisa ficar
   igual dos dois lados. Se a apiKey mudar um dia, atualiza os DOIS
   lugares. */
/* =========================================================================
   OFFLINE (TWA / Play Store): sem internet, o Chrome mostrava a tela padrao
   de "Sem conexao" no lugar do app (motivo de rejeicao/avaliacao ruim). Este
   mesmo Service Worker (um so por escopo) agora guarda o app (HTML/CSS/JS/
   icones) e serve do cache quando a rede falha. Estrategia: rede primeiro
   (sempre pega a versao nova quando ha internet), cache como reserva, com
   limite de 4s pra nao travar em rede ruim. O app em si ja e' local-first
   (localStorage), entao abre e funciona offline; login/nuvem sincronizam
   quando a internet voltar. Mudou os arquivos do shell? Troque o nome do
   cache abaixo so se precisar forcar limpeza -- o conteudo se atualiza sozinho.
   ========================================================================= */
const CACHE_APP = 'dungeonlog-app-v2';
const SHELL_APP = ['style.css', 'assets.js', 'manifest.json', 'icon-192.png', 'icon-512.png'];

const PAGINA_OFFLINE = '<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#282828"><title>Dungeonlog</title><style>' +
  'html,body{margin:0;height:100%;background:#282828;color:#EDEBE7;font-family:system-ui,sans-serif}' +
  'main{min-height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:14px;padding:24px;text-align:center}' +
  'h1{font-size:22px;margin:0}p{margin:0;color:#B8B5AF;line-height:1.5;max-width:300px}' +
  'button{margin-top:10px;background:#EDEBE7;color:#282828;border:0;border-radius:12px;padding:14px 26px;font-size:16px;font-weight:700}' +
  '</style></head><body><main><h1>Sem conexão</h1>' +
  '<p>Abra o Dungeonlog uma vez com internet para ele funcionar offline. Depois disso, ele abre sem conexão.</p>' +
  '<button onclick="location.reload()">Tentar de novo</button></main></body></html>';

// Resposta vinda de REDIRECIONAMENTO (o Cloudflare Pages manda /play/index.html
// pra /play/) NAO pode ser usada pra responder uma navegacao -- o Chrome
// recusa e mostra ERR_FAILED. Copia limpa, sem a marca de redirecionada.
function limpa(resp) {
  if (resp && resp.redirected) {
    return new Response(resp.body, { status: resp.status, statusText: resp.statusText, headers: resp.headers });
  }
  return resp;
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_APP)
      .then(async (c) => {
        // pagina do app: busca a URL "de verdade" do escopo (./ = /play/), nao index.html
        try { const r = await fetch('./', { cache: 'reload' }); if (r.ok) await c.put('index.html', limpa(r)); } catch (e) {}
        await Promise.all(SHELL_APP.map((u) => fetch(u, { cache: 'reload' }).then((r) => r.ok ? c.put(u, limpa(r)) : null).catch(() => {})));
      })
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((ks) => Promise.all(ks.filter((k) => k.startsWith('dungeonlog-app-') && k !== CACHE_APP).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;        // Firebase, fontes, Worker: seguem direto pela rede
  if (url.pathname.indexOf('/play/') !== 0) return;       // so o que e' do app

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_APP);
    const chave = req.mode === 'navigate' ? 'index.html' : req;
    try {
      const resp = await Promise.race([
        fetch(req),
        new Promise((_, rej) => setTimeout(() => rej(new Error('timeout')), 4000)),
      ]);
      if (resp && resp.ok && resp.type === 'basic') cache.put(chave, limpa(resp.clone()));
      return resp;
    } catch (e) {
      const guardado = await cache.match(chave, { ignoreSearch: true });
      if (guardado) return limpa(guardado);
      // sem cache E sem rede: nunca deixa aparecer a tela de erro do Chrome --
      // mostra uma tela propria (so em navegacao; subrecurso ausente = erro normal)
      if (req.mode === 'navigate') return new Response(PAGINA_OFFLINE, { status: 200, headers: { 'Content-Type': 'text/html; charset=utf-8' } });
      return Response.error();
    }
  })());
});

try {
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDbWXdoaGpY6aJpasssrqWrX-nP85c1Vv0",
  authDomain: "questlog-d4c11.firebaseapp.com",
  projectId: "questlog-d4c11",
  storageBucket: "questlog-d4c11.firebasestorage.app",
  messagingSenderId: "991047001122",
  appId: "1:991047001122:web:983cb7e87ea3ea648c567b"
});

const messaging = firebase.messaging();

// Mensagem chegando com o app FECHADO ou em outra aba -- o navegador so
// entrega aqui, no Service Worker, nunca direto pro app. Monta a
// notificacao do sistema operacional manualmente (o SDK nao faz isso
// sozinho pra mensagens "data-only", e' de proposito -- ver payload
// enviado pelas Cloud Functions em /functions/index.js, que manda so
// `data`, nao `notification`, exatamente pra cair aqui sempre, mesmo em
// navegadores/SOs que tratam os dois campos de formas diferentes).
messaging.onBackgroundMessage((payload) => {
  const dados = payload.data || {};
  const titulo = dados.titulo || 'Dungeonlog';
  self.registration.showNotification(titulo, {
    body: dados.corpo || '',
    icon: 'icon-192.png',
    badge: 'icon-192.png',
    data: dados,
  });
});

} catch (e) { /* sem rede na instalacao: so o cache offline funciona ate o proximo update */ }

// Clique na notificacao -- foca uma aba do app ja aberta se existir,
// senao abre uma nova em /play/. Nao usa a URL absoluta (dominio pode
// mudar entre ambientes de teste/producao) -- relativo ao escopo do SW.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil((async () => {
    const lista = await clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const c of lista){
      if (c.url.includes('/play/') && 'focus' in c) return c.focus();
    }
    if (clients.openWindow) return clients.openWindow('./');
  })());
});
