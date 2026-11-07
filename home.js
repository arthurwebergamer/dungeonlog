/* home.js — parallax em camadas (caverna), faixas de monstros ligadas à rolagem e faíscas de clique.
   Sem bibliotecas. Respeita "reduzir movimento" do sistema. */
/* home.js — faixas de monstros ligadas à rolagem, menu do celular, galeria de telas e origem da visita.
   Sem bibliotecas. Respeita "reduzir movimento" do sistema. */
(function () {
  'use strict';
  var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  var shifts = [].slice.call(document.querySelectorAll('.shift[data-sx]'));
  var ticking = false;

  function update() {
    ticking = false;
    var vh = window.innerHeight || 800;
    for (var j = 0; j < shifts.length; j++) {      // filas de monstros andam ao rolar (sentidos opostos)
      var s = shifts[j];
      var r = s.parentNode.getBoundingClientRect();
      if (r.bottom < -100 || r.top > vh + 100) continue;
      var sx = parseFloat(s.getAttribute('data-sx')) || 0;
      s.style.transform = 'translate3d(' + ((r.top - vh / 2) * sx).toFixed(1) + 'px,0,0)';
    }
  }
  function req() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(update);
    setTimeout(function () { if (ticking) update(); }, 90);   // reserva: abas ocultas ou visualizações embutidas pausam o rAF
  }

  if (!reduce) {
    window.addEventListener('scroll', req, { passive: true });
    window.addEventListener('resize', req, { passive: true });
    update();
  }
})();

/* ----- duelo da tela de título: herói e monstro aleatórios; clique no monstro para derrotá-lo ----- */
(function () {
  'use strict';
  var duel = document.getElementById('duel');
  var heroEl = document.getElementById('duelHero');
  var monEl = document.getElementById('duelMon');
  if (!duel || !heroEl || !monEl) return;
  var NMON = 63, NHERO = 8, busy = false;
  var mi = Math.floor(Math.random() * NMON);
  heroEl.style.setProperty('--hi', Math.floor(Math.random() * NHERO));
  monEl.style.setProperty('--mi', mi);
  monEl.addEventListener('click', function () {
    if (busy) return; busy = true;
    duel.classList.add('dead');
    setTimeout(function () {
      var n; do { n = Math.floor(Math.random() * NMON); } while (n === mi);
      mi = n; monEl.style.setProperty('--mi', mi);
      duel.classList.remove('dead'); duel.classList.add('spawn');
      setTimeout(function () { duel.classList.remove('spawn'); busy = false; }, 380);
    }, 650);
  });
})();

/* menu do celular (três linhas): gaveta em tela cheia que desliza da direita */
(function () {
  var btn = document.getElementById('menuBtn'), menu = document.getElementById('menu');
  if (!btn || !menu) return;
  function definir(abrir) {
    menu.classList.toggle('open', abrir);
    menu.setAttribute('aria-hidden', abrir ? 'false' : 'true');
    btn.setAttribute('aria-expanded', abrir ? 'true' : 'false');
    document.body.classList.toggle('menu-open', abrir);
  }
  btn.addEventListener('click', function () { definir(!menu.classList.contains('open')); });
  menu.addEventListener('click', function (e) {
    var a = e.target.closest('a'); if (!a) return;
    var h = a.getAttribute('href') || '';
    if (h.charAt(0) === '#' && h.length > 1) {
      var alvo = document.getElementById(h.slice(1));
      e.preventDefault(); definir(false);
      if (alvo) setTimeout(function () { alvo.scrollIntoView({ behavior: 'smooth', block: 'start' }); if (history.replaceState) history.replaceState(null, '', h); }, 40);
    } else { definir(false); }
  });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') definir(false); });
  window.addEventListener('resize', function () { if (window.innerWidth > 720) definir(false); });
})();

/* galeria de celulares: arrastar com o mouse (a barra de rolagem fica escondida) */
(function () {
  var g = document.querySelector('.gallery');
  if (!g) return;
  var down = false, sx = 0, sl = 0, moved = false;
  g.addEventListener('pointerdown', function (e) {
    if (e.pointerType !== 'mouse' || e.button !== 0) return;
    down = true; moved = false; sx = e.clientX; sl = g.scrollLeft;
    g.style.scrollSnapType = 'none'; g.classList.add('drag');
    try { g.setPointerCapture(e.pointerId); } catch (x) {}
  });
  g.addEventListener('pointermove', function (e) {
    if (!down) return;
    var dx = e.clientX - sx;
    if (Math.abs(dx) > 3) moved = true;
    g.scrollLeft = sl - dx;
  });
  function fim() {
    if (!down) return;
    down = false; g.classList.remove('drag');
    g.style.scrollSnapType = '';           // volta o encaixe no celular mais próximo
  }
  g.addEventListener('pointerup', fim);
  g.addEventListener('pointercancel', fim);
  g.addEventListener('click', function (e) { if (moved) { e.preventDefault(); e.stopPropagation(); moved = false; } }, true);
  g.addEventListener('dragstart', function (e) { e.preventDefault(); });
})();

/* galeria de celulares: clicar numa tela abre ela ampliada, dentro do site */
(function () {
  var g = document.querySelector('.gallery');
  if (!g) return;
  var phones = [].slice.call(g.querySelectorAll('.phone'));
  if (!phones.length) return;
  var en = /^en/i.test(document.documentElement.lang || '');
  var T = en ? { close: 'Close', prev: 'Previous screen', next: 'Next screen', open: 'Enlarge: ' }
             : { close: 'Fechar', prev: 'Tela anterior', next: 'Próxima tela', open: 'Ampliar: ' };
  var box = null, idx = 0, voltar = null;

  function build() {
    box = document.createElement('div');
    box.className = 'lb';
    box.hidden = true;
    box.setAttribute('role', 'dialog');
    box.setAttribute('aria-modal', 'true');
    box.innerHTML =
      '<button class="lb-x" type="button" aria-label="' + T.close + '">&times;</button>' +
      '<button class="lb-nav lb-prev" type="button" aria-label="' + T.prev + '">&#8249;</button>' +
      '<figure class="lb-fig"><img alt="" draggable="false"><figcaption></figcaption></figure>' +
      '<button class="lb-nav lb-next" type="button" aria-label="' + T.next + '">&#8250;</button>';
    document.body.appendChild(box);
    box.addEventListener('click', function (e) {
      if (e.target.closest('.lb-prev')) go(-1);
      else if (e.target.closest('.lb-next')) go(1);
      else if (!e.target.closest('.lb-fig img')) close();   // botão fechar ou clique no fundo
    });
  }
  function show(i) {
    idx = (i + phones.length) % phones.length;
    var p = phones[idx], im = p.querySelector('img'), c = p.querySelector('figcaption');
    var big = box.querySelector('img');
    big.src = im.currentSrc || im.src;
    big.alt = im.alt || '';
    box.setAttribute('aria-label', c ? c.textContent : '');
    box.querySelector('figcaption').textContent = (c ? c.textContent + '  ·  ' : '') + (idx + 1) + '/' + phones.length;
  }
  function open(i) {
    if (!box) build();
    voltar = document.activeElement;
    show(i);
    box.hidden = false;
    document.body.classList.add('lb-open');
    box.querySelector('.lb-x').focus();
  }
  function close() {
    if (!box || box.hidden) return;
    box.hidden = true;
    document.body.classList.remove('lb-open');
    if (voltar && voltar.focus) voltar.focus();
  }
  function go(d) { show(idx + d); }

  phones.forEach(function (p, i) {
    var c = p.querySelector('figcaption');
    p.tabIndex = 0;
    p.setAttribute('role', 'button');
    p.setAttribute('aria-label', T.open + (c ? c.textContent : ''));
    p.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); open(i); }
    });
  });
  // o arrastar com o mouse já cancela o clique quando a galeria foi movida (ver bloco acima)
  g.addEventListener('click', function (e) {
    var p = e.target.closest('.phone');
    if (p) open(phones.indexOf(p));
  });
  document.addEventListener('keydown', function (e) {
    if (!box || box.hidden) return;
    if (e.key === 'Escape') close();
    else if (e.key === 'ArrowLeft') go(-1);
    else if (e.key === 'ArrowRight') go(1);
    else if (e.key === 'Tab') {                              // mantém o foco dentro da janela
      var f = [].slice.call(box.querySelectorAll('button'));
      var i = f.indexOf(document.activeElement);
      e.preventDefault();
      f[(i + (e.shiftKey ? -1 : 1) + f.length) % f.length].focus();
    }
  });
})();

/* Origem da visita: se a URL trouxer ?utm_source=<origem>, repassa ao link da Google Play como "referrer",
   para o Play Console mostrar de onde veio a instalação. Nada é guardado nem enviado por este site. */
(function () {
  'use strict';
  try {
    var src = new URLSearchParams(location.search).get('utm_source');
    if (!src || !/^[a-z0-9_-]{1,30}$/i.test(src)) return;
    var ref = encodeURIComponent('utm_source=' + src + '&utm_medium=bio');
    [].forEach.call(document.querySelectorAll('a[href^="https://play.google.com/store/apps/details?id=com.dungeonlog"]'), function (a) {
      a.href = a.href.split('&referrer=')[0] + '&referrer=' + ref;
    });
  } catch (e) {}
})();
