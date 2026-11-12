// Extrai dados, imagens e textos do app atual (play/) para app-flutter/assets/.
// Uso (a partir da raiz do repositório):  node app-flutter/tools/extrair_assets.mjs
// Fonte da verdade: play/assets.js, play/index.html, play/sheet.png. Nada é editado em play/.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raiz = path.resolve(aqui, '..', '..');
const play = path.join(raiz, 'play');
const saida = path.join(raiz, 'app-flutter', 'assets');

const escreverJson = (rel, obj) => {
  const f = path.join(saida, rel);
  fs.mkdirSync(path.dirname(f), { recursive: true });
  fs.writeFileSync(f, JSON.stringify(obj, null, 1) + '\n');
};
const escreverPng = (rel, b64) => {
  const f = path.join(saida, rel);
  fs.mkdirSync(path.dirname(f), { recursive: true });
  fs.writeFileSync(f, Buffer.from(b64.replace(/^data:image\/png;base64,/, ''), 'base64'));
};
const dataUrlOuB64 = (s) => {
  if (typeof s !== 'string' || !s) throw new Error('imagem ausente');
  return s;
};

// ---------- assets.js ----------
const ctx = {};
vm.createContext(ctx);
vm.runInContext(
  fs.readFileSync(path.join(play, 'assets.js'), 'utf8') +
    ';this.R={MONSTROS,HEROIS,ITENS,TEMAS_ARENA,TEMA_ARENA_TILE_B64};',
  ctx
);
const { MONSTROS, HEROIS, ITENS, TEMAS_ARENA, TEMA_ARENA_TILE_B64 } = ctx.R;
const pad = (n) => String(n).padStart(2, '0');

// monstros: mantém a ordem (o índice entra na conta do monstro do dia)
escreverJson(
  'dados/monstros.json',
  MONSTROS.map((m, i) => {
    escreverPng(`img/monstros/${pad(i)}.png`, dataUrlOuB64(m.img));
    const o = { nome: m.nome, nome_en: m.nome_en };
    if (m.bioma) o.bioma = m.bioma;
    o.img = `assets/img/monstros/${pad(i)}.png`;
    return o;
  })
);

escreverJson(
  'dados/herois.json',
  HEROIS.map((h, i) => {
    escreverPng(`img/herois/${pad(i)}.png`, dataUrlOuB64(h.img));
    const o = { nome: h.nome, nome_en: h.nome_en, img: `assets/img/herois/${pad(i)}.png` };
    if (h.imgArena) {
      escreverPng(`img/herois/${pad(i)}_arena.png`, h.imgArena);
      o.imgArena = `assets/img/herois/${pad(i)}_arena.png`;
    }
    return o;
  })
);

// itens: linhas cruas, mesma ordem e mesmo formato de ITENS (o índice é o id salvo no inventário)
// [spriteIdx, nome, tipo, raridade, valor, bonusMoedas, bonusXp, cura, morto, nome_en]
escreverJson('dados/itens.json', {
  colunas: ['sprite', 'nome', 'tipo', 'raridade', 'valor', 'bonusMoedas', 'bonusXp', 'cura', 'morto', 'nome_en'],
  sheet: { arquivo: 'assets/img/sheet.png', colunas: 16, linhas: 27, tile: 32 },
  linhas: ITENS,
});
fs.mkdirSync(path.join(saida, 'img'), { recursive: true });
fs.copyFileSync(path.join(play, 'sheet.png'), path.join(saida, 'img', 'sheet.png'));

escreverJson(
  'dados/temas_arena.json',
  TEMAS_ARENA.map((t) => {
    const o = { ...t };
    if (t.arte) { escreverPng(`img/arena/${t.id}.png`, t.arte); o.arte = `assets/img/arena/${t.id}.png`; }
    if (t.arteEstagio) { escreverPng(`img/arena/${t.id}_estagio.png`, t.arteEstagio); o.arteEstagio = `assets/img/arena/${t.id}_estagio.png`; }
    return o;
  })
);
escreverPng('img/arena/tile.png', TEMA_ARENA_TILE_B64);

// ---------- index.html: TRADUCOES ----------
const html = fs.readFileSync(path.join(play, 'index.html'), 'utf8');
// pega o literal `const TRADUCOES = { ... };` por contagem de chaves (respeitando strings)
function literalApos(marca) {
  const ini = html.indexOf(marca);
  if (ini < 0) throw new Error('não achei: ' + marca);
  const abre = html.indexOf('{', ini);
  let nivel = 0, aspas = null, esc = false;
  for (let i = abre; i < html.length; i++) {
    const c = html[i];
    if (aspas) {
      if (esc) esc = false;
      else if (c === '\\') esc = true;
      else if (c === aspas) aspas = null;
    } else if (c === '\'' || c === '"' || c === '`') aspas = c;
    else if (c === '{') nivel++;
    else if (c === '}' && --nivel === 0) return html.slice(abre, i + 1);
  }
  throw new Error('literal sem fim: ' + marca);
}
const traducoes = vm.runInNewContext('(' + literalApos('const TRADUCOES = {') + ')');
escreverJson('dados/traducoes.json', traducoes);

// ---------- imagens da interface (embutidas em index.html e style.css) ----------
// pilha de moedas do topo (21x21) e moeda solta do ganho (13x13): <svg viewBox="0 0 N N"><image href="data:...">
const imagemDoSvg = (lado) => {
  const m = html.match(new RegExp('viewBox="0 0 ' + lado + ' ' + lado + '"[^>]*><image href="(data:image/png;base64,[^"]+)"'));
  if (!m) throw new Error('não achei o svg ' + lado + 'x' + lado);
  return m[1];
};
escreverPng('img/ui/moedas.png', imagemDoSvg(21));
escreverPng('img/ui/moeda.png', imagemDoSvg(13));
// tochas da arena: duas folhas 48x32 (3 quadros de 16x32), a direita já espelhada no PNG
const css = fs.readFileSync(path.join(play, 'style.css'), 'utf8');
for (const lado of ['esq', 'dir']) {
  const ini = css.indexOf('.tocha-arena.tocha-' + lado + '{');
  const m = ini < 0 ? null : css.slice(ini, css.indexOf('}', ini)).match(/url\("(data:image\/png;base64,[^"]+)"/);
  if (!m) throw new Error('não achei a tocha ' + lado);
  escreverPng('img/ui/tocha_' + lado + '.png', m[1]);
}

// baús da arena (pack Treasure Chests): variáveis CSS --bau-* em :root, 128x128 cada; e o cadeado do baú trancado
const varCss = (nome) => {
  const m = css.match(new RegExp(nome + String.raw`\s*:\s*url\(["']?(data:image/png;base64,[^"')]+)`));
  if (!m) throw new Error('não achei a variável ' + nome);
  return m[1];
};
escreverPng('img/baus/padrao_fechado.png', varCss('--bau-fechado'));
escreverPng('img/baus/padrao_aberto.png', varCss('--bau-aberto'));
for (let t = 0; t < 4; t++) {
  escreverPng('img/baus/t' + t + '_fechado.png', varCss('--bau-esp-t' + t + '-fechado'));
  escreverPng('img/baus/t' + t + '_aberto.png', varCss('--bau-esp-t' + t + '-aberto'));
}
// cadeado do baú trancado: SVG de retângulos (12x14) embutido no CSS; vira lista [x, y, largura, altura, cor]
let cadeado;
{
  const ini = css.indexOf('.bauArena.trancado::after{');
  const m = ini < 0 ? null : css.slice(ini, css.indexOf('}', ini)).match(/url\(["']?data:image\/svg\+xml,([^"')]+)/);
  if (!m) throw new Error('não achei o cadeado do baú');
  const svg = decodeURIComponent(m[1]);
  const vb = svg.match(/viewBox="0 0 (\d+) (\d+)"/);
  const attr = (t, n) => (t.match(new RegExp(n + '="([^"]+)"')) || [])[1];
  cadeado = {
    largura: +vb[1],
    altura: +vb[2],
    rects: [...svg.matchAll(/<rect [^>]*>/g)].map((r) => [+attr(r[0], 'x'), +attr(r[0], 'y'), +attr(r[0], 'width'), +attr(r[0], 'height'), attr(r[0], 'fill')]),
  };
  if (!cadeado.rects.length) throw new Error('cadeado sem retângulos');
}

// ---------- equipamento desenhado no herói da arena (desenharHeroi) ----------
// EQ_BB: retângulo real do desenho de cada peça [x0,y0,x1,y1] na célula 32x32; ARMA_GRIP: ponto do cabo [gx,gy];
// ARMA_AJUSTE: ajuste fino [dx,dy]; ARMA_ESCURA: armas clareadas (também nos ícones, pelo índice do sprite).
const literalJs = (nome) => {
  const m = html.match(new RegExp(String.raw`window\.` + nome + String.raw`\s*=\s*([^;\n]+);`));
  if (!m) throw new Error('não achei window.' + nome);
  return vm.runInNewContext('(' + m[1] + ')');
};
const armaEscura = [...literalJs('ARMA_ESCURA')];
escreverJson('dados/equip_arena.json', {
  eqBB: literalJs('EQ_BB'),
  armaGrip: literalJs('ARMA_GRIP'),
  armaAjuste: literalJs('ARMA_AJUSTE'),
  armaEscura,
  cadeado,
  spritesEscuros: [...new Set(armaEscura.map((id) => ITENS[id] && ITENS[id][0]).filter((x) => x != null))],
});

console.log(
  `monstros=${MONSTROS.length} herois=${HEROIS.length} itens=${ITENS.length} temas=${TEMAS_ARENA.length} traducoes=${Object.keys(traducoes).length}`
);

// cadeado do cenário trancado na arena (.tema-arena-cadeado-img)
{
  const m = /class="tema-arena-cadeado-img" src="data:image\/png;base64,([A-Za-z0-9+/=]+)"/.exec(fs.readFileSync(path.join(raiz, 'play', 'index.html'), 'utf8'));
  if (m) fs.writeFileSync(path.join(raiz, 'app-flutter', 'assets', 'img', 'ui', 'cadeado_arena.png'), Buffer.from(m[1], 'base64'));
}

// respiração dos monstros por espécie (.gvm-* em play/style.css) -> assets/dados/respiracao.json
{
  const css = fs.readFileSync(path.join(raiz, 'play', 'style.css'), 'utf8');
  const saida = {};
  const re = /\.gvm-(\w+):not\(\.dead\):not\(\.fugiu\) \.mobimg\{([^}]*)\}@keyframes (\w+)\{/g;
  let m;
  while ((m = re.exec(css))) {
    const [, fam, props, nome] = m;
    // corpo dos keyframes: até a chave que fecha o @keyframes
    let i = m.index + m[0].length, prof = 1;
    const ini = i;
    while (i < css.length && prof > 0) { if (css[i] === '{') prof++; else if (css[i] === '}') prof--; i++; }
    const corpo = css.slice(ini, i - 1);
    const dur = /animation-duration:([\d.]+)s/.exec(props);
    const tim = /animation-timing-function:steps\((\d+)/.exec(props);
    const quadros = [];
    for (const b of corpo.matchAll(/([\d.%,\s]+)\{([^}]*)\}/g)) {
      const decl = b[2];
      const q = { tx: 0, ty: 0, rot: 0, sx: 1, sy: 1, op: 1 };
      const t = /transform:([^;]*)/.exec(decl);
      if (t && t[1].trim() !== 'none') {
        for (const f of t[1].matchAll(/(translateX|translateY|translate|rotate|scale)\(([^)]*)\)/g)) {
          const v = f[2].split(',').map((x) => parseFloat(x));
          if (f[1] === 'translateX') q.tx = v[0]; else if (f[1] === 'translateY') q.ty = v[0];
          else if (f[1] === 'translate') { q.tx = v[0]; q.ty = v[1] ?? 0; }
          else if (f[1] === 'rotate') q.rot = v[0];
          else { q.sx = v[0]; q.sy = v.length > 1 ? v[1] : v[0]; }
        }
      }
      const o = /opacity:([\d.]+)/.exec(decl);
      if (o) q.op = parseFloat(o[1]);
      for (const p of b[1].split(',')) quadros.push({ p: parseFloat(p) / 100, ...q });
    }
    quadros.sort((a, b) => a.p - b.p);
    saida[fam] = { dur: dur ? parseFloat(dur[1]) : 1.8, passos: tim ? parseInt(tim[1], 10) : 2, quadros };
  }
  fs.writeFileSync(path.join(raiz, 'app-flutter', 'assets', 'dados', 'respiracao.json'), JSON.stringify(saida));
  console.log('respiração:', Object.keys(saida).length, 'famílias');
}
