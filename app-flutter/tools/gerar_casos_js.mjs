// Gera app-flutter/test/fixtures/casos_js.json: saídas do JS ATUAL (play/index.html + play/assets.js)
// para as regras de jogo. Os testes em Dart precisam dar o mesmo resultado.
//
// As funções NÃO são reescritas aqui: o texto delas é extraído de play/index.html e executado
// num sandbox (vm) do Node. Só o "entorno" (localStorage, relógio, DOM) é simulado.
//
// Uso (raiz do repositório):  node app-flutter/tools/gerar_casos_js.mjs
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raiz = path.resolve(aqui, '..', '..');
const html = fs.readFileSync(path.join(raiz, 'play', 'index.html'), 'utf8');
const assetsJs = fs.readFileSync(path.join(raiz, 'play', 'assets.js'), 'utf8');

/* ---------------- extração de código do index.html ---------------- */
// avança até o fecho correspondente respeitando strings e comentários
function fimBalanceado(src, abre) {
  const par = { '{': '}', '[': ']', '(': ')' };
  let pilha = [], aspas = null, esc = false;
  for (let i = abre; i < src.length; i++) {
    const c = src[i], n = src[i + 1];
    if (aspas) {
      if (esc) esc = false; else if (c === '\\') esc = true; else if (c === aspas) aspas = null;
      continue;
    }
    if (c === '/' && n === '/') { i = src.indexOf('\n', i); if (i < 0) break; continue; }
    if (c === '/' && n === '*') { i = src.indexOf('*/', i) + 1; continue; }
    if (c === '\'' || c === '"' || c === '`') { aspas = c; continue; }
    if (par[c]) pilha.push(par[c]);
    else if (c === pilha[pilha.length - 1]) { pilha.pop(); if (!pilha.length) return i; }
  }
  throw new Error('sem fecho');
}
function fonteFuncao(nome) {
  const m = new RegExp('^(?:async )?function ' + nome + '\\(', 'm').exec(html);
  if (!m) throw new Error('função não achada: ' + nome);
  const abre = html.indexOf('{', html.indexOf(')', m.index));
  return html.slice(m.index, fimBalanceado(html, abre) + 1);
}
function fonteDecl(nome) {            // const/let NOME = ...;   (até o ; do nível zero)
  const m = new RegExp('^(?:const|let) ' + nome + '\\s*=', 'm').exec(html);
  if (!m) throw new Error('declaração não achada: ' + nome);
  let prof = 0, aspas = null, esc = false;
  for (let i = m.index; i < html.length; i++) {
    const c = html[i], n = html[i + 1];
    if (aspas) { if (esc) esc = false; else if (c === '\\') esc = true; else if (c === aspas) aspas = null; continue; }
    if (c === '/' && n === '/') { i = html.indexOf('\n', i); continue; }
    if (c === '/' && n === '*') { i = html.indexOf('*/', i) + 1; continue; }
    if (c === '\'' || c === '"' || c === '`') { aspas = c; continue; }
    if ('{[('.includes(c)) prof++; else if ('}])'.includes(c)) prof--;
    else if (c === ';' && prof === 0) return html.slice(m.index, i + 1);
  }
  throw new Error('decl sem fim: ' + nome);
}
// bloco autônomo "VIDA DO HEROI" (IIFE) — roda inteiro no sandbox
const iniVida = html.lastIndexOf('(function(){', html.indexOf("const CHAVE_VIDA = 'questlog.vida.v1';"));
const fimVida = html.indexOf('\n})();', html.indexOf('window.vidaHeroi = {', iniVida)) + 6;
const fonteVida = html.slice(iniVida, fimVida);

const FUNCOES = ['isoDe', 'diffDias', 'isoAtual', 'diaDaSemana', 'multDif', 'difDe', 'xpDaTarefa', 'moedasDaTarefa',
  'recompensaVitoria', 'precoVenda', 'xpNecessario', 'progresso', 'diaMesOcorreNoDia', 'anualOcorreNoDia',
  'ocorreNoDia', 'ehDeHoje', 'feitaHoje', 'diasCorridos', 'monstroDoDia', 'monstroDoDiaEm', 'estagioAtual',
  'progressoEstagio', 'biomaDoEstagio', 'poolMonstrosFiltrado', 'bonusItem', 'bonusEquip', 'afixoSoma',
  'multMoedas', 'multXP', 'item', 'variante', 'ehEquipBase', 'baseDe', 'limparVariantes', 'exportarVariantes',
  'restaurarVariantes', 'limparAfixosFabrica', 'migrarAfixos', 'afxRolar', 'comAfixo', 'nomePadraoHeroi',
  'nomeHeroiNorm', 'idiomaApp', 'resetarEstadoParaPadrao', 'salvar', '_carregarBase', 'chaveSaveAtual', 'chaveConta',
  'monstroJaCaiu'];
const DECLS = ['ECO', 'BONUS', 'DIFS', 'DIF_PADRAO', 'AFIXOS', 'AFX_CHAVES', 'AFX_TETO', 'AFX_NEG', 'AFX_NEG_CHAVES',
  'P_NEG_LOOT', 'P_SEM_AFX', 'SLOTS', 'LIMIARES_ESTAGIO', 'TIER_RAR', '_varMapa', '_restoMoedasTarefa'];

/* ---------------- sandbox ---------------- */
function criarSandbox({ lang = 'pt', uid = null, pj = 'pj1', relogio = null } = {}) {
  const store = new Map();
  store.set('questlog.idioma.v1', lang);
  const localStorage = {
    getItem: (k) => (store.has(k) ? store.get(k) : null),
    setItem: (k, v) => { store.set(k, String(v)); },
    removeItem: (k) => { store.delete(k); },
    get length() { return store.size; },
    key: (i) => [...store.keys()][i] ?? null,
  };
  const window = {};
  const base = {
    console, Math, JSON, Set, Array, Object, Number, String, parseInt, isNaN, Map,
    localStorage, window,
    document: { getElementById: () => null, querySelector: () => null, querySelectorAll: () => [] },
    setTimeout: (f) => { f(); return 0; }, clearTimeout() {},
  };
  const ctx = vm.createContext(base);
  const run = (c) => vm.runInContext(c, ctx);
  run('Date.now = () => 1700000000000;');
  run(assetsJs);
  run(`let _uidAtivo = ${JSON.stringify(uid)}, _personagemAtivo = ${JSON.stringify(pj)};`);
  run('const BASE_N = ITENS.length;');
  for (const d of DECLS) run(fonteDecl(d));
  for (const f of FUNCOES) run(fonteFuncao(f));
  run(`let tarefas = [], xpTotal = 0, moedas = 0, derrotadoEm = null, nomeHeroi = nomePadraoHeroi(),
        heroiEscolhido = 0, semente = 7, inventario = [], equipado = {arma:null, armadura:null, elmo:null, escudo:null, acess:null};
       let diaOffset = 0, __hoje = [2026, 10, 11];
       function dataAtual(){ return new Date(__hoje[0], __hoje[1], __hoje[2], 10, 0, 0); }
       window.__bloquearSalvar = false; window.EH_DEV = false;
       window.totalTarefasConcluidas = () => __total; let __total = 0;
       let __bioma = null; function temaArenaAtual(){ return TEMAS_ARENA.find(t => t.id === __bioma) || TEMAS_ARENA[0]; }
       if (!__bioma) { __bioma = TEMAS_ARENA[0].id; }
       window.chaveConta = chaveConta; window.diaDescansando = (iso) => __descanso.includes(iso || isoAtual()); let __descanso = [];
       function render(){} function aviso(){}`);
  // Math.random fixo (só usado na migração de contas legadas, cujo resultado líquido não depende dele)
  run('Math.random = () => 0.5;');
  return { ctx, run, store, window };
}

/* ---------------- gerador pseudoaleatório fixo ---------------- */
function mulberry32(a) { return () => { a |= 0; a = (a + 0x6D2B79F5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }
const rnd = mulberry32(20261111);
const rint = (a, b) => a + Math.floor(rnd() * (b - a + 1));
const pick = (arr) => arr[Math.floor(rnd() * arr.length)];
const iso = (y, m, d) => `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;

/* ---------------- configurações de equipamento ---------------- */
const S0 = criarSandbox();
const baseN = S0.run('BASE_N');
const linhas = S0.run('ITENS.map(r => r.slice(0, 10))');
const SLOTS = ['arma', 'armadura', 'elmo', 'escudo', 'acess'];
function basePorSlotRar(slot, rar) { return linhas.findIndex((r) => r[2] === slot && r[3] === rar && !r[8]); }
const negativos = linhas.map((r, i) => [i, r]).filter(([, r]) => !r[8] && SLOTS.includes(r[2]) && (r[5] < 0 || r[6] < 0));

function configEquip(nome, porSlot, variantes = []) {
  return { nome, variantes, porSlot };   // porSlot: slot -> {base, afx?:[tipo,val], rer?}
}
const configs = [configEquip('vazio', {})];
for (const rar of [0, 2, 4, 5, 6]) {
  const porSlot = {};
  for (const s of SLOTS) { const b = basePorSlotRar(s, rar); if (b >= 0) porSlot[s] = { base: b }; }
  configs.push(configEquip('todos-rar' + rar, porSlot));
}
configs.push(configEquip('gan-est-no-teto', {
  arma: { base: basePorSlotRar('arma', 3), afx: ['gan', 20] }, armadura: { base: basePorSlotRar('armadura', 3), afx: ['gan', 15] },
  elmo: { base: basePorSlotRar('elmo', 3), afx: ['est', 20] }, escudo: { base: basePorSlotRar('escudo', 3), afx: ['est', 18] },
}));
configs.push(configEquip('maldicoes', {
  arma: { base: basePorSlotRar('arma', 2), afx: ['gan', -4] }, elmo: { base: basePorSlotRar('elmo', 2), afx: ['est', -3] },
  acess: { base: basePorSlotRar('acess', 1), afx: ['gan', -30] },
}));
if (negativos.length) {
  const porSlot = {}; for (const [i, r] of negativos.slice(0, 5)) porSlot[r[2]] = { base: i };
  configs.push(configEquip('itens-negativos-do-catalogo', porSlot));
}
configs.push(configEquip('afixo-nao-xp', { arma: { base: basePorSlotRar('arma', 4), afx: ['sor', 3] }, escudo: { base: basePorSlotRar('escudo', 4), afx: ['bau', 5], rer: 2 } }));

// resolve as variantes e devolve o que o JS enxerga
function aplicarEquip(S, cfg) {
  const lista = [];
  const equip = {}; SLOTS.forEach((s) => { equip[s] = null; });
  for (const s of SLOTS) {
    const e = cfg.porSlot[s]; if (!e) continue;
    if (e.afx || e.rer) { lista.push([e.base, e.afx ? e.afx[0] : null, e.afx ? e.afx[1] : 0, e.rer || 0]); equip[s] = baseN + lista.length - 1; }
    else equip[s] = e.base;
  }
  S.run(`restaurarVariantes(${JSON.stringify(lista)}); equipado = ${JSON.stringify(equip)};`);
  return { variantes: lista, equipado: equip };
}

const casos = {};
casos.geradoCom = { node: process.version, baseN };

/* ---------------- constantes ---------------- */
casos.constantes = JSON.parse(S0.run(`JSON.stringify({ECO, BONUS, DIFS, DIF_PADRAO, AFX_TETO, LIMIARES_ESTAGIO, SLOTS, TIER_RAR})`));

/* ---------------- equipamento, XP, moedas ---------------- */
casos.equipamento = configs.map((cfg) => {
  const S = criarSandbox();
  const eq = aplicarEquip(S, cfg);
  const dif = ['trivial', 'facil', 'media', 'dificil', 'invalida', null];
  const xp = [];
  for (let ordem = 1; ordem <= 14; ordem++) for (const d of dif) xp.push({ ordem, dif: d, xp: S.run(`xpDaTarefa(${ordem}, ${JSON.stringify(d)})`) });
  const vit = [];
  for (let n = 0; n <= 12; n++) vit.push({ n, moedas: S.run(`recompensaVitoria(${n})`) });
  // moedas por tarefa: acumulador com resto fracionário entre chamadas
  const seqs = [];
  for (let k = 0; k < 4; k++) {
    S.run('_restoMoedasTarefa = 0;');
    const difs = Array.from({ length: 30 }, () => pick(['trivial', 'facil', 'media', 'dificil', undefined]));
    seqs.push({ difs: difs.map((d) => d ?? null), moedas: difs.map((d) => S.run(`moedasDaTarefa(${JSON.stringify(d ?? null)})`)) });
  }
  return { nome: cfg.nome, ...eq, bonus: JSON.parse(S.run('JSON.stringify(bonusEquip())')), multXP: S.run('multXP()'), multMoedas: S.run('multMoedas()'), xp, vitoria: vit, moedasSeqs: seqs };
});
// valor de venda
casos.venda = linhas.map((r, i) => ({ id: i, preco: S0.run(`precoVenda({tipo:${JSON.stringify(r[2])}, val:${r[4]}})`) })).filter((_, i) => i % 3 === 0);

/* ---------------- nível ---------------- */
casos.nivel = [0, 1, 99, 100, 101, 159, 260, 261, 500, 1000, 5000, 12345, 99999, 1000000, 'x', -5].map((xp) => {
  const S = criarSandbox(); S.run(`xpTotal = ${JSON.stringify(xp)};`);
  return { xp, progresso: JSON.parse(S.run('JSON.stringify(progresso())')) };
});
casos.xpNecessario = Array.from({ length: 30 }, (_, i) => ({ nivel: i + 1, xp: S0.run(`xpNecessario(${i + 1})`) }));

/* ---------------- ganho por conclusão (expressões de alternar(), linhas ~6419/6456) ---------------- */
casos.ganhoMeta = [];
for (const meta of [1, 2, 3, 5, 9]) for (const ordem of [0, 1, 5, 10, 11, 14]) for (const dif of ['trivial', 'facil', 'media', 'dificil']) {
  const S = criarSandbox();
  casos.ganhoMeta.push({ meta, ordem, dif, xp: S.run(`Math.max(1, Math.round(xpDaTarefa(${ordem}, ${JSON.stringify(dif)}) / ${meta}))`), moedas: S.run(`Math.max(1, Math.round(moedasDaTarefa(${JSON.stringify(dif)}) / ${meta}))`) });
}

/* ---------------- datas ---------------- */
casos.isoDe = [[2026, 0, 1], [2026, 11, 31], [2024, 1, 29], [2026, 2, 8], [2026, 9, 18], [2026, 10, 1]].map(([y, m, d]) => ({ y, m: m + 1, d, iso: S0.run(`isoDe(new Date(${y},${m},${d},23,59,0))`), isoManha: S0.run(`isoDe(new Date(${y},${m},${d},0,1,0))`) }));
const paresDiff = [['2026-11-11', '2026-11-10'], ['2026-11-10', '2026-11-11'], ['2026-03-01', '2026-02-01'], ['2024-03-01', '2024-02-01'],
  ['2026-10-18', '2026-10-17'], ['2026-11-01', '2026-10-31'], ['2027-01-01', '2026-01-01'], ['2026-11-11', '2026-11-11'], ['lixo', '2026-11-11'], ['', '2026-01-01'], ['2026-02-30', '2026-02-28'], ['2026-04-31', '2026-04-30'], ['2026-13-01', '2026-01-01'], ['2026-11-1', '2026-11-01']];
casos.diffDias = paresDiff.map(([a, b]) => ({ a, b, dias: S0.run(`diffDias(${JSON.stringify(a)}, ${JSON.stringify(b)})`) }));

// ocorreNoDia: arquétipos de tarefa × todos os dias de 2023-12-01 a 2026-03-31
const arquetipos = [
  { tipo: 'hoje', data: '2026-02-10' }, { tipo: 'hoje', data: '2024-02-29' },
  { tipo: 'repete', dias: [0, 1, 2, 3, 4, 5, 6] }, { tipo: 'repete', dias: [1, 3, 5] }, { tipo: 'repete', dias: [] },
  { tipo: 'repete', dias: [0, 6], pulaEm: ['2026-02-07', '2026-02-08', '2025-12-13'] },
  { tipo: 'mensal', diaMes: 15 }, { tipo: 'mensal', diaMes: 31 }, { tipo: 'mensal', diaMes: 30 }, { tipo: 'mensal', diaMes: 29 }, { tipo: 'mensal' }, { tipo: 'mensal', diaMes: 0 },
  { tipo: 'mensal', diaMes: 31, pulaEm: ['2026-01-31'] },
  { tipo: 'anual', diaAno: 31, mesAno: 12 }, { tipo: 'anual', diaAno: 29, mesAno: 2 }, { tipo: 'anual', diaAno: 31, mesAno: 4 }, { tipo: 'anual', diaAno: 1, mesAno: 1 },
  { tipo: 'anual' }, { tipo: 'anual', diaAno: 10, mesAno: 13 }, { tipo: 'anual', diaAno: 10, mesAno: 0 },
  { tipo: 'repete' }, { texto: 'sem tipo', dias: [2] },
];
const inicio = Date.UTC(2023, 11, 1), fim = Date.UTC(2026, 2, 31);
const dias = []; for (let t = inicio; t <= fim; t += 86400000) dias.push(new Date(t).toISOString().slice(0, 10));
casos.ocorrencias = { de: dias[0], ate: dias[dias.length - 1], tarefas: arquetipos.map((t) => {
  const S = criarSandbox();
  S.run(`var __t = ${JSON.stringify(t)};`);
  const datas = dias.filter((d) => { try { return S.run(`ocorreNoDia(__t, ${JSON.stringify(d)})`); } catch (e) { return false; } });
  return { tarefa: t, datas };
}) };

/* ---------------- estágio ---------------- */
casos.estagio = [0, 1, 9, 10, 11, 29, 30, 31, 69, 70, 71, 500].map((total) => {
  const S = criarSandbox(); S.run(`__total = ${total};`);
  return { total, estagio: S.run('estagioAtual()'), progresso: S.run('progressoEstagio()'), bioma: S.run('biomaDoEstagio(estagioAtual())') };
});

/* ---------------- itens e variantes ---------------- */
casos.bonusItens = linhas.map((r, i) => i).filter((i) => i % 2 === 0).map((i) => ({ id: i, ...JSON.parse(S0.run(`JSON.stringify(bonusItem(item(${i})))`)) }));

/* ---------------- save: carregar e salvar ---------------- */
const idsEq = (n) => Array.from({ length: baseN }, (_, i) => i).filter((i) => linhas[i][2] && SLOTS.includes(linhas[i][2]) && !linhas[i][8]).slice(0, n);
const eqIds = idsEq(8);
const consIds = linhas.map((r, i) => [r, i]).filter(([r]) => (r[2] === 'cons' || r[2] === 'chave' || r[2] === 'tesouro') && !r[8]).map(([, i]) => i).slice(0, 6);
const mortos = linhas.map((r, i) => [r, i]).filter(([r]) => r[8]).map(([, i]) => i);
const tarefaBase = (o) => Object.assign({ texto: 'Tarefa', tipo: 'repete', dias: [0, 1, 2, 3, 4, 5, 6], dif: 'media' }, o);
const savesEntrada = [
  { nome: 'minimo', json: { versao: 3, comecou: true } },
  { nome: 'sem-comecou', json: { versao: 3, xpTotal: 50, tarefas: [tarefaBase()] } },
  { nome: 'json-invalido', raw: '{nao e json' },
  { nome: 'vazio', raw: null },
  { nome: 'completo', json: {
      versao: 3, afixos: 2, comecou: true, xpTotal: 345, moedas: 1200, derrotadoEm: '2026-11-10', nomeHeroi: 'Arthur', heroi: 3, semente: 41, salvoEm: 1699999999999,
      tarefas: [tarefaBase({ texto: 'Ler', feitaEm: '2026-11-10', dif: 'dificil', corBox: '#F2A65A', categoriaId: 'cat_x1' }),
        tarefaBase({ texto: 'Meta', meta: 3, vezesData: '2026-11-10', vezesN: 2, extraDesconhecido: { a: 1 } }),
        { texto: 'Mensal', tipo: 'mensal', diaMes: 31, pulaEm: ['2026-10-31'] }, { texto: 'Hoje', tipo: 'hoje', data: '2026-11-11' }],
      variantes: [[eqIds[0], 'gan', 2, 0], [eqIds[1], null, 0, 1], [eqIds[2], 'est', -3, 0]],
      inventario: [{ id: baseN, q: 1 }, { id: baseN + 1, q: 2 }, { id: eqIds[3], q: 1 }, { id: consIds[0], q: 5 }, { id: consIds[1], q: 1 }],
      equipado: { arma: baseN, armadura: baseN + 1, elmo: null, escudo: eqIds[3], acess: null } } },
  { nome: 'itens-mortos', json: { versao: 3, afixos: 2, comecou: true, inventario: [{ id: mortos[0], q: 1 }, { id: consIds[0], q: 2 }, { id: 99999, q: 1 }, null], equipado: { arma: mortos[0], elmo: eqIds[2] } } },
  { nome: 'campos-estranhos', json: { versao: 3, afixos: 2, comecou: true, xpTotal: '120', moedas: 'abc', heroi: '2', nomeHeroi: 'Adventurer', semente: '12', tarefas: 'nao-lista', inventario: {}, equipado: 5 } },
  { nome: 'nome-padrao-aventureiro', json: { versao: 3, afixos: 2, comecou: true, nomeHeroi: 'Aventureiro' } },
  { nome: 'nome-vazio', json: { versao: 3, afixos: 2, comecou: true, nomeHeroi: '' } },
  { nome: 'legado-sem-afixos', json: { versao: 3, comecou: true, inventario: [{ id: eqIds[0], q: 2 }, { id: eqIds[1], q: 1 }, { id: consIds[0], q: 3 }], equipado: { arma: eqIds[0], elmo: null } } },
  { nome: 'afixos-1', json: { versao: 3, afixos: 1, comecou: true, variantes: [[eqIds[0], 'gan', 2, 0], [eqIds[0], 'gan', 4, 1], [eqIds[1], 'est', 1, 0]],
      inventario: [{ id: baseN, q: 1 }, { id: baseN + 1, q: 1 }, { id: baseN + 2, q: 1 }], equipado: { arma: baseN + 1, armadura: baseN + 2 } } },
  { nome: 'variante-invalida', json: { versao: 3, afixos: 2, comecou: true, variantes: [[eqIds[0], 'zzz', 2, 0], [99999, null, 0, 0], [eqIds[1], 'bau', 4, 2], 'lixo'], inventario: [{ id: baseN, q: 1 }] } },
];
const descItem = `function __desc(id){ if (id === null || id === undefined) return null; const a = ITENS[id]; if (!a) return {invalido:id};
  return { base: baseDe(id), afx: a[10] ? [a[10][0], a[10][1]] : null, rer: a[11] || 0 }; }`;
casos.saves = savesEntrada.map((s) => {
  for (const lang of ['pt', 'en']) {
    if (lang === 'en' && !['nome-padrao-aventureiro', 'nome-vazio', 'completo'].includes(s.nome)) continue;
  }
  const out = [];
  for (const lang of (['nome-padrao-aventureiro', 'nome-vazio', 'completo'].includes(s.nome) ? ['pt', 'en'] : ['pt'])) {
    const S = criarSandbox({ lang, uid: null, pj: 'pj1' });
    S.run(descItem);
    const bruto = 'raw' in s ? s.raw : JSON.stringify(s.json);
    if (bruto !== null) S.store.set('questlog.v1.pj.pj1', bruto);
    const carregou = S.run('_carregarBase()');
    const estado = JSON.parse(S.run(`JSON.stringify({ tarefas, xpTotal, moedas, derrotadoEm, nomeHeroi, heroiEscolhido, semente,
      inventario: inventario.map(s => ({ item: __desc(s.id), q: s.q })), equipado: Object.fromEntries(SLOTS.map(k => [k, __desc(equipado[k])])) })`));
    let salvo = null;
    if (carregou) { S.run('salvar();'); salvo = JSON.parse(S.store.get('questlog.v1.pj.pj1')); }
    out.push({ idioma: lang, carregou, estado, salvo });
  }
  return { nome: s.nome, entrada: 'raw' in s ? s.raw : JSON.stringify(s.json), resultados: out };
});
casos.chaves = [[null, 'pj1'], ['abc123', 'pj1'], ['abc123', 'pj2'], [null, 'pj2']].map(([uid, pj]) => {
  const S = criarSandbox({ uid, pj });
  return { uid, pj, save: S.run('chaveSaveAtual()'), vida: S.run("chaveConta('questlog.vida.v1')"), descanso: S.run("chaveConta('questlog.descanso.v1')") };
});

/* ---------------- virada do dia + vida (bloco VIDA DO HEROI, executado inteiro) ---------------- */
function tarefaAleatoria(ultimo) {
  const tipo = pick(['repete', 'repete', 'repete', 'hoje', 'mensal', 'anual']);
  const t = { texto: 'T' + rint(1, 999), tipo, dif: pick(['trivial', 'facil', 'media', 'dificil', undefined, 'lixo']) };
  if (t.dif === undefined) delete t.dif;
  if (tipo === 'repete') t.dias = [0, 1, 2, 3, 4, 5, 6].filter(() => rnd() < 0.6);
  if (tipo === 'hoje') t.data = ultimo ?? '2026-11-10';
  if (tipo === 'mensal') t.diaMes = rint(1, 31);
  if (tipo === 'anual') { t.diaAno = rint(1, 31); t.mesAno = rint(1, 12); }
  if (rnd() < 0.2) t.pulaEm = [ultimo ?? '2026-11-10'];
  if (rnd() < 0.3) t.feitaEm = ultimo ?? '2026-11-10';
  return t;
}
function cenarioVirada(i) {
  const hojeD = new Date(Date.UTC(2026, 10, 11 + rint(-2, 20)));
  const hoje = hojeD.toISOString().slice(0, 10);
  const salto = pick([0, 1, 1, 1, 2, 3, 8, -1, -3]);
  const ultimo = rnd() < 0.08 ? null : new Date(hojeD.getTime() - salto * 86400000).toISOString().slice(0, 10);
  const nT = rint(0, 7);
  let tarefas = Array.from({ length: nT }, () => tarefaAleatoria(ultimo));
  if (i % 5 === 0) tarefas = tarefas.map((t) => Object.assign(t, { tipo: 'repete', dias: [0, 1, 2, 3, 4, 5, 6], feitaEm: ultimo ?? hoje }));   // dia todo concluído: vitória automática
  if (i % 7 === 0) tarefas = tarefas.map((t) => Object.assign(t, { tipo: 'repete', dias: [0, 1, 2, 3, 4, 5, 6], feitaEm: undefined, dif: 'dificil' })).concat(Array.from({ length: 9 }, () => ({ texto: 'x', tipo: 'repete', dias: [0, 1, 2, 3, 4, 5, 6], dif: 'dificil' })));   // dano alto: queda
  const nivelXp = pick([0, 50, 100, 400, 1500, 6000]);
  const vidaIni = pick([null, 1, 5, 12, 40, 88, 200]);
  const cfg = pick(configs);
  return { hoje, ultimo, vidaIni, xpTotal: nivelXp, moedas: pick([0, 7, 100, 1001]), derrotadoEm: pick([null, ultimo, '2000-01-01']),
    descanso: rnd() < 0.2 ? [ultimo, hoje].filter(Boolean).concat(rnd() < 0.5 ? ['2026-11-09'] : []) : [], tarefas, cfg };
}
casos.virada = Array.from({ length: 160 }, (_, i) => {
  const c = cenarioVirada(i);
  const S = criarSandbox();
  const eq = aplicarEquip(S, c.cfg);
  const [y, m, d] = c.hoje.split('-').map(Number);
  S.run(`__hoje = [${y}, ${m - 1}, ${d}]; __descanso = ${JSON.stringify(c.descanso)};
         tarefas = ${JSON.stringify(c.tarefas)}; xpTotal = ${c.xpTotal}; moedas = ${c.moedas}; derrotadoEm = ${JSON.stringify(c.derrotadoEm)};`);
  if (c.ultimo !== null || c.vidaIni !== null) S.store.set(S.run("chaveConta('questlog.vida.v1')"), JSON.stringify({ vida: c.vidaIni ?? 40, ultimoDia: c.ultimo }));
  const antesMoedas = c.moedas;
  S.run(fonteVida);
  const vidaFinal = S.run('window.vidaHeroi.get()');
  const gravado = JSON.parse(S.store.get(S.run("chaveConta('questlog.vida.v1')")) || 'null');
  return {
    entrada: { hoje: c.hoje, ultimoDia: c.ultimo, vida: c.vidaIni === null && c.ultimo === null ? null : (c.vidaIni ?? 40), xpTotal: c.xpTotal, moedas: antesMoedas, derrotadoEm: c.derrotadoEm,
      descanso: c.descanso, tarefas: c.tarefas, variantes: eq.variantes, equipado: eq.equipado },
    saida: { vida: vidaFinal, vidaMax: S.run('window.vidaHeroi.max()'), ultimoDia: gravado && gravado.ultimoDia, moedas: S.run('moedas'),
      historico: S.run('JSON.stringify(window._histPendentes || [])') && JSON.parse(S.run('JSON.stringify(window._histPendentes || [])')) },
  };
});
casos.vidaMax = [0, 100, 260, 1000, 5000, 20000].map((xp) => { const S = criarSandbox(); S.run(`xpTotal=${xp};`); S.run(fonteVida); return { xp, vidaMax: S.run('window.vidaHeroi.max()') }; });

/* ---------------- dias corridos / monstro do dia, em vários fusos ---------------- */
if (process.argv.includes('--tz')) {
  const S = criarSandbox();
  const temas = S.run('TEMAS_ARENA.map(t => t.id)');
  const dts = [[2026, 11, 11], [2026, 11, 12], [2026, 12, 31], [2027, 1, 1], [2024, 2, 29], [2026, 10, 18], [2026, 2, 8], [2026, 3, 29], [2026, 11, 1], [2020, 1, 1], [2000, 1, 1], [2026, 6, 15]];
  const saida = [];
  for (const [y, m, d] of dts) {
    S.run(`__hoje = [${y}, ${m - 1}, ${d}];`);
    const off = S.run(`-new Date(${y}, ${m - 1}, ${d}).getTimezoneOffset()`);
    const dc = S.run('diasCorridos()');
    const monstros = [];
    for (const bioma of temas) for (const semente of [0, 1, 7, 33, 63]) {
      S.run(`__bioma = ${JSON.stringify(bioma)}; semente = ${semente};`);
      const alvos = [-3, -1, 0, 1, 2, 40].map((k) => new Date(Date.UTC(y, m - 1, d + k)).toISOString().slice(0, 10));
      monstros.push({ bioma, semente, pool: S.run('poolMonstrosFiltrado().length'), hoje: S.run('MONSTROS.indexOf(monstroDoDia())'),
        em: alvos.map((a) => ({ iso: a, idx: S.run(`MONSTROS.indexOf(monstroDoDiaEm(${JSON.stringify(a)}))`) })) });
    }
    saida.push({ y, m, d, offsetMinutosLeste: off, diasCorridos: dc, monstros });
  }
  process.stdout.write(JSON.stringify(saida));
  process.exit(0);
}
const fusos = ['America/Sao_Paulo', 'UTC', 'Asia/Tokyo', 'Europe/Lisbon', 'America/New_York', 'Pacific/Auckland', 'Asia/Kolkata', 'America/St_Johns'];
casos.fusos = fusos.map((tz) => ({ tz, datas: JSON.parse(execFileSync(process.execPath, [fileURLToPath(import.meta.url), '--tz'], { env: { ...process.env, TZ: tz }, maxBuffer: 1 << 28 }).toString()) }));
casos.temasArena = S0.run('TEMAS_ARENA.map(t => t.id)');
casos.nMonstros = S0.run('MONSTROS.length');

const dest = path.join(raiz, 'app-flutter', 'test', 'fixtures', 'casos_js.json');
fs.mkdirSync(path.dirname(dest), { recursive: true });
fs.writeFileSync(dest, JSON.stringify(casos));
console.log('gravado', dest, (fs.statSync(dest).size / 1024).toFixed(0) + ' KB', 'virada=' + casos.virada.length, 'fusos=' + casos.fusos.length);
