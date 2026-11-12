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

console.log(
  `monstros=${MONSTROS.length} herois=${HEROIS.length} itens=${ITENS.length} temas=${TEMAS_ARENA.length} traducoes=${Object.keys(traducoes).length}`
);
