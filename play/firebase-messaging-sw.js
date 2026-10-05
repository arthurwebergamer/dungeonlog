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

const PAGINA_OFFLINE = '<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#282828"><title>Dungeonlog</title><style>html,body{margin:0;height:100%;background:#282828;color:#FAFAFA;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif}main{min-height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;text-align:center;padding:32px;box-sizing:border-box}img{width:56px;height:56px;image-rendering:pixelated;animation:r .5s ease-in-out infinite}@keyframes r{0%,100%{transform:translateY(0) rotate(-4deg)}50%{transform:translateY(-10px) rotate(4deg)}}#t{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:12px;color:#909090;letter-spacing:.02em;max-width:280px}#m,#b{display:none}#m{font-size:14px;color:#FAFAFA;max-width:260px;line-height:1.4}#b{font-weight:700;font-size:15px;border:0;border-radius:999px;background:#fff;color:#282828;height:46px;padding:0 26px;font-family:inherit}.e img{animation:q 1.1s cubic-bezier(.3,.7,.4,1) forwards;transform-origin:50% 88%;margin-bottom:14px}@keyframes q{0%{transform:translateY(-10px) rotate(4deg)}28%{transform:translateY(0) rotate(0) scale(1.12,.86)}40%{transform:translateY(0) rotate(0) scale(.96,1.04)}55%{transform:translateY(-4px) rotate(-14deg)}75%{transform:translateY(0) rotate(-72deg)}100%{transform:translateY(-2px) rotate(-90deg)}}.e #t{color:#E5698A;animation:s .4s .9s both}.e #m{display:block;animation:s .4s 1.05s both}.e #b{display:block;animation:s .4s 1.2s both}@keyframes s{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}@media (prefers-reduced-motion:reduce){img{animation:none}.e img{transform:rotate(-90deg)}}</style></head><body><main id="x"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACIAAAAiCAYAAAA6RwvCAAAEj0lEQVR42s2YX0hbZxjGf4lBaGv8F42mGDJHZqI4sWqFVrwYzuKEteLY6KAUXL0pFNYWBqXQsu1idAwyh0Jv5kXHmIowulrE4TYoo1okSyUVTVxIK5GlxhoTyCCtbdyF/Q7n5H/Ui30g5nvyvud7zvM+75fzHfifDNVektWa/G3xOfbyxd6ulcui8X8Al08bUn4vJ7pviqg1+dtiUTFso36JiG3Uj5yYHMtGrbxcSjC7EOFYvZaWJj2tHU2UxIIAtDTpMenUHKvX0nOmnQJNlMOGQ5h0amYXImzHXn2xJ0Xk0sar0dKkp6rOwuqiO+G/3RFQKJKNj1SZSAgCLU16AKrqLACUGI6z6Z9J+VlOKJsyqTJ5Ip5A/MJiDiQltrroBsDuCKQlk9IjKnXe57MLEUw6Nf/4/6VAE6WwvExaNBrxSbHRiE8xP6A1ckBrJBrxUVheRmF5GQWaaFrPaLIxq/CDuGtBJt2QK5LKM1nvI6I08rIkI1NiOC7N48tWVWeRyivfc7JSRB4oSIhay5VZXXTzdkefYi4fopPkN3L5tTJqTf623Ct56bql50x7UhJyyd94U0004pPmwksAheVlrC66+ePXJQ4bDgGk3F80qUoCcPvHPxU+iScRP796fYivvryQQLqlSZ+0lTN6xDbqVwTLfSJfNNn86vUh7I5AgoriRlK1cIIiIkCUKJkSzoCF0xcGAQs43Hw99BMA730klN7BBRG7I6C4TrJ9JKv2FbKKO1/frqG7u5vJyUnMFc+kuMHBQQkvVy1LZdqXxwC7I8D5vms4lws533cNAINhx0MTExOKWDEX38vz5B7ZFRHbqJ/h8REFptVqOWh8zq27Awr81t0BDhqfo9VqFfjw+EjazSwjEZF84/ud7tlYWdqpcXiGsqNblB3dUsQLLBaeUcSL/HRksnowEsa90t/OuQ8/psRYQZG+NGV8OBBk07fG8PiIRCLTw1HWRBobGgDoai2ip7URnamWEmNF4m+Mb42NlSVuz80zNRcGYN7pzEhEk60anR3v8NfDh8x5AOZhbj5t3pxHRWlpMc1HjjDvdCZs6TkRESQ+u/Qp/ec+4YbFSmdnJ8vPdACEQsGEnOJiUbIg09PTeNwuAL759ru0ZDIqcqW/nZ7aGGaLFY/bhWrrIqHQAMXFpdTW1iXE+/1PCYWCqLYu4nG7MFusfFAbI6+/XfLLro8Tzb29xMIzeL1eQut2tNYxadF4EgBa6xihdTter5dYeIbm3t79O9eEA0Hu3bEBEHk0y6vKm1SfHMPlPMGD30txOU9QfXKMV5U3iTyaBeDeHRvhQHDv5xrRLV2tRQBMzYWJVJt5t6Wav6faAGg765Hi7/9gBuCtrvv8Zn9MwWOPIjdd92T1WyPaUD7ev7RJcGODQGBNwtrOQqlOh2spfe6uicSPlSderK+NuvLEK+F6fYUMy+0onNUBq7GhgXmnU8LNp3qprC8G4OlCSMLlmOeXnyVcnp+qNGnNKpKSXURvqkFvqgGQFpVjmfL3/FpCqGQ+1asgkQzL5VXFrt5pxB8HYi9fqJJhuVzzP8I/dIxkYyj2AAAAAElFTkSuQmCC" alt=""><span id="t">Conectando com a masmorra...</span><span id="m">O Dungeonlog precisa de internet para abrir. Conecte-se e tente de novo.</span><button id="b" onclick="location.reload()">Tentar de novo</button></main><script>setTimeout(function(){document.getElementById("t").textContent="Sem conexão";document.getElementById("x").className="e"},1800)</script></body></html>';

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
    // sem rede declarada pelo aparelho (modo aviao etc.): responde na hora com a
    // tela offline, sem tentar fetch nem abrir o cache -- evita a espera antes do loading
    if (req.mode === 'navigate' && self.navigator && self.navigator.onLine === false) {
      return new Response(PAGINA_OFFLINE, { status: 200, headers: { 'Content-Type': 'text/html; charset=utf-8' } });
    }
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
