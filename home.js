/* home.js — parallax em camadas (caverna), faixas de monstros ligadas à rolagem e faíscas de clique.
   Sem bibliotecas. Respeita "reduzir movimento" do sistema. */
(function () {
  'use strict';
  var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  var scene = document.getElementById('scene');
  var layers = scene ? [].slice.call(scene.querySelectorAll('[data-sx],[data-sy]')) : [];
  var shifts = [].slice.call(document.querySelectorAll('.shift[data-sx]'));
  var mx = 0, my = 0, ticking = false;

  function update() {
    ticking = false;
    var y = window.pageYOffset || 0;
    var vh = window.innerHeight || 800;

    if (layers.length && y < scene.offsetHeight + 300) {
      for (var i = 0; i < layers.length; i++) {
        var l = layers[i];
        var sx = parseFloat(l.getAttribute('data-sx')) || 0;   // deslocamento horizontal por px rolado
        var sy = parseFloat(l.getAttribute('data-sy')) || 0;   // deslocamento vertical por px rolado
        var ax = parseFloat(l.getAttribute('data-mx')) || 0;   // intensidade do mouse
        l.style.transform = 'translate3d(' + (y * sx + mx * ax).toFixed(1) + 'px,' + (y * sy + my * ax * 0.6).toFixed(1) + 'px,0)';
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
    window.addEventListener('resize', req, { passive: true });
    window.addEventListener('pointermove', function (e) {
      if (e.pointerType !== 'mouse') return;
      mx = (e.clientX / window.innerWidth - 0.5) * -1;
      my = (e.clientY / window.innerHeight - 0.5) * -1;
      req();
    }, { passive: true });
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

/* menu do celular (três linhas) */
(function () {
  var btn = document.getElementById('menuBtn'), menu = document.getElementById('menu');
  if (!btn || !menu) return;
  function fechar() { menu.hidden = true; btn.setAttribute('aria-expanded', 'false'); }
  btn.addEventListener('click', function (e) {
    e.stopPropagation();
    var abrir = menu.hidden;
    menu.hidden = !abrir; btn.setAttribute('aria-expanded', abrir ? 'true' : 'false');
  });
  menu.addEventListener('click', function (e) { if (e.target.closest('a')) fechar(); });
  document.addEventListener('click', function (e) { if (!menu.hidden && !menu.contains(e.target)) fechar(); });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') fechar(); });
  window.addEventListener('resize', function () { if (window.innerWidth > 720) fechar(); });
})();
