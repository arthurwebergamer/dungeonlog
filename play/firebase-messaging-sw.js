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
  'html,body{margin:0;height:100%;background:#282828;color:#EDEBE7;font-family:Georgia,"Times New Roman",serif}' +
  'body{background:radial-gradient(ellipse at 50% 38%,#3a3630 0,#282828 62%)}' +
  'main{min-height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;padding:24px;text-align:center}' +
  'svg{width:150px;height:auto;margin-bottom:6px}' +
  '.rune{animation:p 2.4s ease-in-out infinite}@keyframes p{0%,100%{opacity:.35}50%{opacity:1}}' +
  'small{letter-spacing:.28em;text-transform:uppercase;font-size:11px;color:#C9A24A;font-family:system-ui,sans-serif}' +
  'h1{font-size:26px;margin:0;font-weight:700}' +
  'p{margin:0;color:#B8B5AF;line-height:1.55;max-width:290px;font-size:15px}' +
  'button{margin-top:14px;background:#C9A24A;color:#282828;border:0;border-radius:12px;padding:14px 28px;font-size:16px;font-weight:700;font-family:system-ui,sans-serif;box-shadow:0 4px 0 #8a6d2c}' +
  'button:active{transform:translateY(3px);box-shadow:0 1px 0 #8a6d2c}' +
  '</style></head><body><main>' +
  '<svg viewBox="0 0 120 140" fill="none" stroke-linejoin="round"><path d="M14 138V58C14 26 36 8 60 8s46 18 46 50v80Z" fill="#1d1c1a" stroke="#6b645a" stroke-width="4"/>' +
  '<path d="M30 138V60c0-22 14-36 30-36s30 14 30 36v78Z" fill="#14130f" stroke="#4a453d" stroke-width="3"/>' +
  '<path d="M60 24v114M30 82h60" stroke="#4a453d" stroke-width="2"/>' +
  '<rect x="46" y="74" width="28" height="24" rx="4" fill="#C9A24A" stroke="#8a6d2c" stroke-width="2"/>' +
  '<path d="M51 74v-8a9 9 0 0 1 18 0v8" stroke="#C9A24A" stroke-width="4" stroke-linecap="round"/>' +
  '<circle cx="60" cy="86" r="3" fill="#14130f"/>' +
  '<g class="rune" stroke="#C9A24A" stroke-width="2.5" stroke-linecap="round"><path d="M60 38v10M55 43h10"/><path d="M22 112l6-6m0 6l-6-6M98 112l-6-6m0 6l6-6"/></g></svg>' +
  '<small>Portal selado</small><h1>Sem conexão</h1>' +
  '<p>As runas do reino se apagaram. O Dungeonlog precisa de internet para abrir a masmorra — reconecte e tente de novo.</p>' +
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
      // navegacao sem rede: SEMPRE a tela "Sem conexao" (o app exige internet)
      if (req.mode === 'navigate') return new Response(PAGINA_OFFLINE, { status: 200, headers: { 'Content-Type': 'text/html; charset=utf-8' } });
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
