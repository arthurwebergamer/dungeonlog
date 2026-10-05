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

const PAGINA_OFFLINE = '<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#282828"><title>Dungeonlog</title><style>html,body{margin:0;height:100%;background:#282828;color:#FAFAFA;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif}main{min-height:100%;display:flex;flex-direction:column;justify-content:center;padding:20px;box-sizing:border-box;max-width:460px;margin:0 auto}.arena{position:relative;overflow:hidden;border-radius:18px;padding:34px 16px 22px;text-align:center;background:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAKCAYAAADVTVykAAABfElEQVR4nJ2TwU7CQBCGvxKMQeCEXojGlMvWIw/AnfIOwh0egYfwpIneQJ4Bn4L22r10SeCoJ0CDJVkvdNPWgsT/srM738x0Z6fWZDKpPwyHdLpdlFK0222yklIyHY3o9HoHmVMUBAFvr6+49/copXBdl6KUkkW0JgxDGo0GUspfgUIInnefKKWwbTuXOUWO4/ASbZjP56ZWAeD6rILrugcD/1vwUJ5kBwsAH6sVUkqEEMbheR6e5xm7tNXYtp3LJLnkmrUBSludqmXd1mp1nQCuKpVUgN5/YJ5q1SrW3l5EGwBuzsosok1qjfW+XgPwdW6Z82K33wdg9PREr9//c8iklIwfH+kOBoRhePTpYn46HnPXagH8yl2Mjcty+eggxhJCUKtWT2Jjfrq38wa4kNz8dZv4RstofRIb84toc7CrpgPL3WcuoLVO7X3fB20Zn2VZeWHpHEd8pgPZ6QSYzWamqO/7ADSbTUrfmiAIcBzHsNm/ITn9F5ncSd8PSsnXJX9WpAwAAAAASUVORK5CYII=) repeat,linear-gradient(180deg,#454545 0%,#383838 55%,#2C2C2C 100%);background-size:130px 41px,auto;image-rendering:pixelated}.t{position:absolute;top:4px;width:16px;height:32px;background-size:48px 32px;image-rendering:pixelated;transform:scale(1.7);animation:c .6s steps(3) infinite}.te{left:4px;transform-origin:top left;background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAgCAYAAABU1PscAAACoklEQVR4nO2WTUgbQRiG34RekkAPEcRDNLDKgudCWqHBgiLdICXQU2jEUoQYvJZcwx56kXrooWAgh0oqgZ5yCEZKPQQLSYVSCj2FJJKfgwiRUqiewvQQZtnZnf3Ryq6HvBA2O7vP9843s/PNAGONNdZYd1b7KyJxuw9W8lq98D9J3NYAmMUxTeDF54YnHA/dqCNOzR43AVHwEfqbWb1U2uwGpe/KzR4T6zr8/opI6NXM38ODU3IGU4UiztYSmCoUEY6H0Cn1ITd7aLSvdIyWz85NK/fheAjz0joAYGFp0xZP/ami+SCONy64/l4zmF7pLKTkjOlMiIKP1I52ITd7inGn1Mdh6g2SiSJqR7u2+Fx2G9F8UBkAAPj4R+D6e9VwSs4gl91WzNUBwvEQvrz/ZpgENV9Y2mS4aD6IcDyE5P22aRJansaYWb3E8cYFAHD9TRdxNB9URv86ys5NM5zdGB++thVey+U+/QYAvHwsMAyTgPpht+xHYJhGYJhGt+y33QlqruXpjJrJyD+aD6Jb9jNJchMARt+53OyhU+orbfPSOpaf/MTy1kPdCGh1tpYAAEPeSik5o+MDwzReva2Z+4uCjyS3npPB6R7ZKWSJuvyJgo/sFLJkcLpHpEdPuSXRLd6jDhCRYgCAd6+fcZNMJkZVqXVe1ZUzt3jDIDwNvv/lmrvJM2ug0b7ynFQObmTuFs/diQFgdnJRaWudVxkTow64weuqEM+ABrMyd4O/ZxRo4kGAuW9VrKzd4bk7sfZbPKkc2Bo9N3jD47SdNiM5yesSoIc69SICRt+hnU44zeuO0xEphh/1X9zgESlmeRx2mtdtZPT/7OSicnahR2z1s0r90LAEO8kzVYhdKFUyUQ8wEBXP3C3+WpuKkfFd5cdyQv8A0LgoFtXx0DYAAAAASUVORK5CYII=)}.td{right:4px;transform-origin:top right;background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAgCAYAAABU1PscAAACuUlEQVR4nO2WP2gaURzHv4YsKnSwEDL4By5yU5dSSA1EUkgIMTi4ShVCCZjQoZvrcUMX6VpQcGhJgtBJisRSkkFSsAmELoWCqOCfQYSGUqhO4TrY38Pz3p2XNHgZ7gvi3Xu/z+/fvXf3AFu2bNmyZaCjTVExmp+7LXhXCfwvq1vAXeo2RRxtikog5sXzzzWHkR23AFFwKuREFJwK/ZsNLgpOhX5yvaPyaZYHAH90oPLFs9VUJwpORQr6EM57cLZ7xcZ7yThyUga15tCwI6LgVKqnWQDAj/J7tIpdNifXO6Z4KehDIOZFq9hFLxnH4kFBN/7cJJyS0zj8LQAAAjEvACCc9yAnZVA9zRp2kpJPxAv4lHqNVrGLcN7DkjfDp+Q0gFH3AWDxoMD+U3Jaw89NwidvzwEAZ7tX8EcHrAgAWFnf001iPPnEgyYCMS9LnnxM4yk+2Y83EAByUkZThOoJ7KyOOp/78IuNUSekoA8A8O5Lk9M7rYija+JvIn90wJLXk6oASq5dciGc98B9vQ/39T7aJRezoSKNFM570C65NLzZIvzRAZfnxZ8fv6HJF1IG1UiWjdNGpPVppI2XT7HxbLRfJvleMm7IUnweL9c73PiqAhLxAg4LcUBOY2V9T2WYktPYWRXw6s1H3QSs4NkrSRScytLCGgCMnHBE8EX5WPM6s4rnOnn4xM11oBfcSl61iWvNoaPRr+Dn5Z8bB7eK536J6ZoeKQA0+hUWRC8BK3jNWYgMxuHJOSPNmp/XWP3T5DpslKeFtobnnkZrzaHjonzM7qetXSt5w+P0tDE9zZLXFDD+PiYtLaxxT4J6wWfJa47Ty5FtruNvX79jObI99Tg8a55t4khoS2n0Kxhfe49DjwAAJ5fnqnGerOJVGyMS2mLVNfoVUDfMbkIreO4gOTL78blvvK1Z6i8q7hIvKJXHLAAAAABJRU5ErkJggg==)}@keyframes c{from{background-position-x:0}to{background-position-x:-48px}}.f{display:flex;align-items:flex-end;justify-content:center;gap:28px;margin-bottom:16px}.f img{width:78px;height:78px;image-rendering:pixelated}.g{filter:grayscale(.5);opacity:.55}.vs{font-family:Georgia,serif;font-size:12px;color:#909090;align-self:center}h1{font-family:Georgia,serif;font-style:italic;font-weight:700;font-size:26px;margin:0 0 4px}.z{font-size:13px;color:#C2C2C2}.box{padding:22px 4px 0;text-align:center}p{margin:0;font-size:14px;line-height:1.5;color:#C2C2C2}button{margin-top:18px;background:#fff;color:#282828;border:0;border-radius:14px;padding:14px 28px;font-size:15px;font-weight:700;font-family:inherit}button:active{transform:scale(.97)}</style></head><body><main><div class="arena"><div class="t te"></div><div class="t td"></div><div class="f"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACIAAAAiCAYAAAA6RwvCAAAEdElEQVR42s2YTUwbVxDHfwbLqlAtLxDzIbrBbgzYbWUStVxC6YVCW6R8QC455ZC0t0gJh95Q1FY9RMohoByQcqM3DqVURFCVRpWAOD1QJTJtbYQxi5coAQy4CFVKHNge3Lfa9TeYQ5+E2Dc78+b/Zv4zfm/hfzIspRiXWW2aeD54/aq0tQ7jNP0P4KMPz+Z8bwR6bBEps9o04VSMmbmADmRmLoARmFFWTLTKD5OC1ZhK40kZWZZpbW3FQmrDsixTKTloPCnT0dGBpmk4HA4qJQerMRXtYP/rkiJiDG16NGRZxuVyoShKxn9VVU0RKYZHlkIgBABZlgFwuVwA+Hw+QqFQzmcjoGLSZCnEiXQA6Y7FHMgKTFEUAFRVzQsmJ0csZeVfrcZUKiUHu7u7aJqGJEm603g8ruvG43HT3Ol04nQ6icfjSJKEJElompaXM9ZiyCr4IHYtwOQbxojk4kzRfUSkxpiWbGB8Pp8+T0+by+XS02vsOUUBMSoKEIqi6PkWYBRFMfFDURQTCKEvwMiynBNMeb5q6ejoyFjQ6ERVVSoqKojH4/pccAlAkiQURWFhYQGHwwGQs79Yc6UEYHZ21sSTdBDp87Fbl+j75vsM0LIsZy3lgqmZmQuYlI08MTrNNh+7dQlVVTOiKDaSq4QzIiIURIqyRcJms3H59gQ2mw1VVfl15AYAn3wxDKDLBRBVVU3rZOsjRZWvWFTsfLOhm56eHiYnJ2l+4y9d7969e7rc+exnPU3HcgxQVZXhi37+2Zhj+KIfgPr6egAmJiZMumIu3hvtjBw5EpCZuQADU2aHdrudCvklIw8GTfKRB4NUyC+x2+0m+cDURN5mVhCIMP7h4TMAAko09SI2zom2JCfakiZ9XRYbN+kL+3xgijoYCeL2djbw7WfnqPU3UXnqrZz6O8trrAeXGJia0EEUOhwVDeS0P8UPt3OLHt+7nHW9Ta2/KUN3PbhEQIkyGfqTlc1qAJ4Gg6UDEdH4sv8Gvz95kuqO5csFwf+9fwqA98+c4c7doYJRsRYL4vNrV7nd4qWrqwuLvQ2ARGI7w0aSqlIPiW2mp6eJLIYBuHN3iDKrTcsFpmAf6e1soDkZwtPiJbIYxpK8SSIxiCRV4fO9k6H//PkLEoltLMmbRBbDeFq8NCdD9HY26Hw58nXiav81iI0TjUZJbM5j947qTtNBANi9oyQ254lGoxAbT9kf171mZ3mN+0PXAdhbeMx+3TDu86OEg9389rCKcLAb9/lR9uuG2Vt4DMD9oevsLK+Vfq8R1eJ2bgGwslnNntvDxx+4WfqpHYD2KxFd/9F3HgCaPn3EL/MrvLkSMdnmq56ifmtEGRrHuf4dtre22NhY12XtV6CquppwKL/tkYGkj1Ulivc/oq6KbgvU1NQaZIe7Chd1wTrt9/M0GNTlngt91L2XOoW9+COhy42yyI9jutxonys1eckqjLItUtPYTE1jM4Du1CgrZF/yZwkRJc+FPhOIbLLDfKo40jeN9BP4wetXlmyyw6z5L0g5dCxhZyrWAAAAAElFTkSuQmCC" alt=""><span class="vs">VS</span><img class="g" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAEnklEQVR4nM2XbWiTVxTHfzfJnexNLchcBde5F9mKKyLTtaNDMbUMhhOammLn8EMd+zLYrB/WsRTpGrFfWoXuy8AOim8061M2xpjkZSKWtlSR0kkKQ8aCYBkTqnXd0DS5+5De2zx5HpOUfdgOhNz387/nnP+554H/WMS/PkFKZdrp9IrPW9mGfGVL8uWpk6b90SdHEBmFyi6WfW75AKRUnaF2ALZsWGWGb9x+4Fga7uotG4Rnpcq1UjfFWvr7TyE8Poe13MRXFgAX2bJhFTduPyARHaW19YBt7tKVUZRXQLb0OeVZAJgYn2b9uo3m98fDZ0hERwE4f/6CWff7nVvlHgms0ALfff8Dq9eueeT8pSujK1JeNgCRyblz4f48C/fnbXPVm6tI/pKyWeHJp1eXDaC4C6RUSKmUV+DfvROAoTNDDJ0ZAsDfWE/l8xtt43f+zFBbV2Pb70ZfLe4WkFKJjOLE8W4APusIAfDuvr20vN9ilGvxN9ab8ZamnWY8EAiY9khkWLlR08lVKVXPkmKAmzPTnD77DQD5VCwmE+PTxBJxA2D7tq3mIoUg7BZY4vtbrz3BlZ//sk0FAgG6w31s2lTNSy9soLauhonxaTPfUPs6HV+cyLUb97gCc6NmSRqmZudMuzPUztGPP+Dmr7c5e+6ibd2nx3toOxSk7VCQeDTGHn8DlmXZ1vQc73YkKNcY0LdP/HSZWCJOZ6idnvBJCDSRJMXB994GYP26jWbPvr3vMHVtzHaOZk8xcQDIN2u+dISOEO7qpSnYTHImBUCSlG1NxeMeBgYjhI4dZWJ8Omdy4Or1KbZv28rV61MON9gAiIwyFHIDEjp2lHBXLwAqu4jw+Mx//hqAqsoKmwW+On2BDw8fYP7uPWKJuNJP9/JOKVVoKcq18ng05qBJYYClZueoqqww/dnfcqlY54eRyDDKKzh8cD8dn3fSGWonHo2hoZkgzEdrEknupkLfWs/l/wD8u3dSVVlhA9Id7jOUCwQCzP2dNTTWrlkGIKXSpgt39dId7rPdUnkFieiowy06Fr4+961tfGAwUjQAO0PtprhxBKEOIIM0C6TTYmxyUgHEEnEAXnz2OVoPN1P9ahUAQyOXWfeUdxl0QcKZvXXLrIWcxZUGUA5dDPI8OXvuoqGkTsH6iS4l+nIe08mT2roak0weVdkkZ5bzwaNEeHyqKdjMSGQYf2O9KzgfgHR5EjQo5RUIfKrt4H66w328uWMHsPzk5sfFwv15xiYnCQSbsSxLUWBZf2M9yZmU3RUAUj6mFjNZw2GAnvBJdvn9xKMxANoOBW2HDQxGHID147PjlZcBzNvQFGy2rbUsC1seSKcfCqRUyZkU83fvsXrtGnb5/cQu/gggCt0wMBhxBJnA6SrlFZBOi5HIsDL9nEKzd5kF6bSwLEuBLSiF8PhU4e3dXjWVXRSWZeWqZwXxiWu2OcC1SC1ZuwuPT9XVvWH61Ztz/nNYQUq1x99g2xtLxEt+LRWvCaVUZJSt7C588dyktq6GbQ3NGoQqBqJkUdrff6psxVo0MzSdi2WZ4i5Yqg1hiY55tHL99MorPkuu/b/IPxh2AezmHucbAAAAAElFTkSuQmCC" alt=""></div><h1>Sem conexão</h1><div class="z">0 / 1</div></div><div class="box"><p>O Dungeonlog precisa de internet para abrir. Conecte-se e tente de novo.</p><button onclick="location.reload()">Tentar de novo</button></div></main></body></html>';

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
