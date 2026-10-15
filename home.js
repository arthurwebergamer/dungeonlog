/* home.js — parallax em camadas (caverna), faixas de monstros ligadas à rolagem e faíscas de clique.
   Sem bibliotecas. Respeita "reduzir movimento" do sistema. */
(function () {
  'use strict';
  var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  var scene = document.getElementById('scene');
  var layers = scene ? [].slice.call(scene.querySelectorAll('[data-sx],[data-sy]')) : [];
  var shifts = [].slice.call(document.querySelectorAll('.shift[data-sx]'));
  var mx = 0, my = 0, ticking = false;

  /* Cada camada só precisa ser larga o bastante para o deslocamento máximo dela (altura do cenário × velocidade
     + mouse). Camadas gigantes e iguais ocupavam centenas de MB de GPU; o navegador descartava pedaços ao descer
     a página e, ao subir direto, redesenhava tudo aos poucos (blocos escuros/borrados). */
  function sizeLayers() {
    if (!scene) return;
    var h = scene.offsetHeight || window.innerHeight || 800;
    for (var i = 0; i < layers.length; i++) {
      var l = layers[i];
      var sx = Math.abs(parseFloat(l.getAttribute('data-sx')) || 0);
      var ax = Math.abs(parseFloat(l.getAttribute('data-mx')) || 0);
      var m = Math.ceil(h * sx + ax / 2 + 48) + 'px';
      l.style.left = '-' + m; l.style.right = '-' + m;
    }
  }

  function update() {
    ticking = false;
    var y = window.pageYOffset || 0;
    var py = scene ? Math.min(y, scene.offsetHeight) : y;   // o cenário não anda além da própria altura
    var vh = window.innerHeight || 800;

    if (layers.length && y < scene.offsetHeight + 300) {
      for (var i = 0; i < layers.length; i++) {
        var l = layers[i];
        var sx = parseFloat(l.getAttribute('data-sx')) || 0;   // deslocamento horizontal por px rolado
        var sy = parseFloat(l.getAttribute('data-sy')) || 0;   // deslocamento vertical por px rolado
        var ax = parseFloat(l.getAttribute('data-mx')) || 0;   // intensidade do mouse
        l.style.transform = 'translate3d(' + (py * sx + mx * ax).toFixed(1) + 'px,' + (y * sy + my * ax * 0.6).toFixed(1) + 'px,0)';
      }
    }
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
    window.addEventListener('resize', function () { sizeLayers(); req(); }, { passive: true });
    window.addEventListener('pointermove', function (e) {
      if (e.pointerType !== 'mouse') return;
      mx = (e.clientX / window.innerWidth - 0.5) * -1;
      my = (e.clientY / window.innerHeight - 0.5) * -1;
      req();
    }, { passive: true });
    sizeLayers();
    update();

    /* faíscas douradas ao clicar (só mouse) */
    window.addEventListener('pointerdown', function (e) {
      if (e.pointerType !== 'mouse') return;
      for (var i = 0; i < 8; i++) {
        var sp = document.createElement('span');
        var a = (Math.PI * 2 * i) / 8, d = 18 + Math.random() * 18;
        sp.className = 'spark';
        sp.style.left = e.clientX + 'px'; sp.style.top = e.clientY + 'px';
        sp.style.setProperty('--dx', (Math.cos(a) * d).toFixed(1) + 'px');
        sp.style.setProperty('--dy', (Math.sin(a) * d).toFixed(1) + 'px');
        document.body.appendChild(sp);
        (function (el) { setTimeout(function () { el.remove(); }, 480); })(sp);
      }
    });
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
