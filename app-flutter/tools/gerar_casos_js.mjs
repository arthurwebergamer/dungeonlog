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
const html = fs.readFileSync(path.join(raiz, 'play', 'index.html'), 'utf8').split(String.fromCharCode(13, 10)).join(String.fromCharCode(10));
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
  'monstroJaCaiu', 'sortearItem', 'tesouroExtra', 'lootDoEstagio',
  'gerarEstadoBauDia', 'darLoot', 'sortearGanhos', 'mediaDifHoje', 'pipsDe', 'chanceBauTrancado', '_fatorDif', 'tierBauNecessario',
  '_lerPityBau', '_gravarPityBau', 'darItem', 'tirarItem', 'acharSlot', 'persistir', 'chaveParaDestravar', 'nivelMinimo',
  'pesosLojaPorNivel', 'precoLoja', 'rngLoja', 'montarEstoque', 'pNegForja'];
const DECLS = ['ECO', 'BONUS', 'DIFS', 'DIF_PADRAO', 'AFIXOS', 'AFX_CHAVES', 'AFX_TETO', 'AFX_NEG', 'AFX_NEG_CHAVES',
  'P_NEG_LOOT', 'P_SEM_AFX', 'SLOTS', 'LIMIARES_ESTAGIO', 'TIER_RAR', '_varMapa', '_restoMoedasTarefa', 'PESO_RAR', 'RAR_ESCALA', 'PITY_BAU_ESPECIAL', 'CHAVE_PITY_BAU', 'PESO_TIER_ESPECIAL', 'LOJA_TIPOS', 'PESO_LOJA',
  'ID_GRIMORIO_LOJA', 'ID_GRIMORIO_INV'];

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
       function render(){} function aviso(){} let abaAtual = 'tarefas'; window.afixoSoma = afixoSoma;`);
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

/* ---------------- Estatísticas (Fase 4): o módulo real do index.html rodando contra um DOM falso ---------------- */
// As funções de render (renderEstatisticas, renderUltimos7Dias, renderMapaDoMes, renderHistoricoSemana/Ano...) são as
// do index.html, sem alteração. Só o DOM é simulado (El): o que elas escrevem nos elementos é o que o Dart precisa igualar.
function gerarEstatisticas() {
  const indentFn = (nome) => {
    const m = new RegExp('^[ \\t]+function ' + nome + '\\(', 'm').exec(html);
    if (!m) throw new Error('função indentada não achada: ' + nome);
    const abre = html.indexOf('{', html.indexOf(')', m.index));
    return html.slice(m.index, fimBalanceado(html, abre) + 1);
  };
  const fonteEst = [
    ...['estStreakAtual', 'estRecorde', 'estHistComHojeAoVivo', 'renderEstatisticas', 'renderUltimos7Dias', 'renderDonutMes',
      'preencherTileDia', 'renderMapaDoMes', 'renderHistoricoSemana', 'renderHistoricoAno', 'renderHistoricoConteudo',
      'corAccentComOpacidade'].map(fonteFuncao),
    ...['NOMES_MES_CURTO', 'estPeriodoAtual', 'estAnoEscolhido', '_donutMesAnterior'].map(fonteDecl),
    ...['escalaTocha', 'corDoStreak', 'escalaTochaCompartilhar'].map(indentFn),
  ].join('\n');

  class El {
    constructor(tag = 'div') {
      this.tag = tag; this.children = []; this._cls = new Set(); this.dataset = {}; this.attrs = {}; this._text = '';
      this.disabled = false; this.parent = null; this._nom = {}; this._st = {};
      const st = this._st;
      this.style = new Proxy({}, {
        get: (_, k) => (k === 'setProperty' ? (a, b) => { st[a] = String(b); } : k === 'getPropertyValue' ? (a) => st[a] ?? '' : st[k]),
        set: (_, k, v) => { st[k] = v; return true; },
      });
    }
    get className() { return [...this._cls].join(' '); }
    set className(v) { this._cls = new Set(String(v).split(/\s+/).filter(Boolean)); }
    get classList() {
      const s = this._cls;
      return {
        add: (...c) => c.forEach((x) => s.add(x)), remove: (...c) => c.forEach((x) => s.delete(x)),
        toggle: (c, f) => { const on = f === undefined ? !s.has(c) : !!f; if (on) s.add(c); else s.delete(c); return on; },
        contains: (c) => s.has(c),
      };
    }
    appendChild(c) { c.parent = this; this.children.push(c); return c; }
    setAttribute(k, v) { this.attrs[k] = String(v); if (k === 'class') this.className = v; }
    get textContent() { return this._text; }
    set textContent(v) { this._text = String(v); this.children = []; }
    set innerHTML(v) { this.children = []; }
    get innerHTML() { return ''; }
    querySelector(sel) { const k = sel.replace(/^\./, ''); return (this._nom[k] ||= new El()); }
    querySelectorAll(sel) { const k = sel.replace(/^\./, ''); return this.children.filter((c) => c._cls.has(k)); }
    remove() { if (this.parent) this.parent.children = this.parent.children.filter((x) => x !== this); }
    getTotalLength() { return 100; }
    getBoundingClientRect() { return {}; }
  }
  const S = criarSandbox();
  S.run('let HIST = []; window.obterHistorico = () => HIST.slice();');
  S.run(fonteEst);
  S.run('window.escalaTocha = escalaTocha; window.corDoStreak = corDoStreak; window.matchMedia = () => ({ matches: true });');
  S.run("window.t = (k) => k + ':{recorde}:{faltam}';");
  const ctx = S.ctx;
  ctx.getComputedStyle = () => ({ getPropertyValue: () => '#FFFFFF' });

  // entradas: sempre as mesmas (gerador fixo)
  const r = mulberry32(4242);
  const ri = (a, b) => a + Math.floor(r() * (b - a + 1));
  const hojes = ['2026-11-21', '2026-12-31', '2027-01-01', '2026-03-01', '2024-02-29', '2026-02-28', '2026-01-31', '2026-10-31', '2025-12-01',
    '2026-07-04', '2023-03-12', '2026-11-01', '2028-02-29', '2026-09-30', '2026-06-15', '2026-04-30'];
  const dia = (hoje, n) => { const [y, m, d] = hoje.split('-').map(Number); return new Date(Date.UTC(y, m - 1, d - n)).toISOString().slice(0, 10); };
  const res = ['vitoria', 'vitoria', 'vitoria', 'fuga', 'descanso', 'sem_tarefa'];
  const casos = [];
  for (let i = 0; i < 330; i++) {
    const hoje = hojes[i % hojes.length];
    const modo = i % 6;
    const hist = [];
    if (modo !== 0) {
      let d = modo === 5 ? ri(1, 5) : ri(0, 3);
      const n = ri(1, modo === 1 ? 90 : modo === 2 ? 260 : 40);
      for (let k = 0; k < n && d < 800; k++) {
        const rr = modo === 3 ? (r() < 0.93 ? 'vitoria' : 'fuga') : res[ri(0, 5)];
        hist.push({ data: dia(hoje, d), resultado: rr, monstroId: ri(0, 62), tarefas: ri(0, 5) });
        d += r() < 0.85 ? 1 : ri(2, 6);
      }
      if (i % 7 === 0 && hist.length) hist.push({ ...hist[ri(0, hist.length - 1)], resultado: res[ri(0, 5)] }); // data repetida
      if (i % 5 === 0) hist.reverse();
      if (i % 11 === 0) hist.push({ data: dia(hoje, -ri(1, 5)), resultado: 'vitoria', monstroId: 0, tarefas: 1 }); // futuro
    }
    const nT = [0, 1, 2, 3][i % 4];
    const feitas = ri(0, nT);
    const periodo = ['mes', 'semana', 'ano'][i % 3];
    const anoEsc = periodo === 'ano' && i % 2 === 0 ? Number(hoje.slice(0, 4)) - ri(0, 2) : null;
    casos.push({ hoje, lang: i % 5 === 4 ? 'en' : 'pt', hist, tarefas: { total: nT, feitas: i % 3 === 0 ? nT : feitas }, descanso: i % 13 === 0, total: ri(0, 900), periodo, anoEsc });
  }

  function rodar(c) {
    const [y, m, d] = c.hoje.split('-').map(Number);
    S.store.set('questlog.idioma.v1', c.lang);
    S.run(`__hoje = [${y}, ${m - 1}, ${d}]; HIST = ${JSON.stringify(c.hist)}; __total = ${c.total}; __descanso = ${JSON.stringify(c.descanso ? [c.hoje] : [])};`);
    const tar = [];
    for (let k = 0; k < c.tarefas.total; k++) tar.push({ texto: 't' + k, tipo: 'repete', dias: [0, 1, 2, 3, 4, 5, 6], dif: 'media', meta: 1, feitaEm: k < c.tarefas.feitas ? c.hoje : null });
    S.run(`tarefas = ${JSON.stringify(tar)};`);
    S.run(`window.idiomaAtual = () => ${JSON.stringify(c.lang)}; estPeriodoAtual = ${JSON.stringify(c.periodo)}; estAnoEscolhido = ${c.anoEsc === null ? 'null' : c.anoEsc};`);
    const ids = {};
    const doc = {
      getElementById: (id) => (ids[id] ||= new El()),
      querySelector: () => null,
      querySelectorAll: (sel) => (sel === '#estTabsPeriodo button' ? ['semana', 'mes', 'ano'].map((t) => { const e = new El('button'); e.dataset.tab = t; return e; }) : []),
      documentElement: new El(),
      createElement: (t) => new El(t),
      createElementNS: (_, t) => new El(t),
    };
    ctx.document = doc;
    S.run('renderEstatisticas();');
    const txt = (id) => (ids[id] ? ids[id]._text : null);
    const out = {
      seq: { streak: txt('estStreakNum'), cor: ids.estStreakNum.style.color, escala: ids.estTochaPrincipal.style.transform, apagada: ids.estTochaPrincipal._cls.has('est-tocha-apagada'), lbl: txt('estStreakLbl') },
      geral: [txt('estTotalConcluidas'), txt('estTotalVitorias'), txt('estTaxaGeral')],
      taxa: { num: txt('estTaxaNum'), pct: ids.estTaxaRing.style.getPropertyValue('--pct'), fundo: ids.estTaxaRing.querySelector('.est-ringtrack').style.background ?? null },
      donut: {
        total: txt('estDonutTotal'), v: txt('estQtdVitoria'), f: txt('estQtdFuga'), s: txt('estQtdSemTarefa'), d: txt('estQtdDescanso'),
        bv: ids.estBarraVitoria.style.width, bf: ids.estBarraFuga.style.width, bs: ids.estBarraSemTarefa.style.width, bd: ids.estBarraDescanso.style.width,
        fundo: ids.estDonutMes.style.background,
      },
      mesLabel: txt('estMesLabel'),
      graf: {
        linha: ids.est7DiasLinha.attrs.d, area: ids.est7DiasArea.attrs.d,
        circulos: ids.est7DiasSvg.children.filter((c2) => c2._cls.has('est-chartponto')).map((c2) => [c2.attrs.cx, c2.attrs.cy, c2.attrs.fill]),
        rotulos: ids.est7DiasLabels.children.map((c2) => [c2._text, c2.className]),
      },
      anoSwitch: { on: ids.estAnoSwitcher._cls.has('on'), num: txt('estAnoNum'), proxDesab: ids.estAnoProximo ? ids.estAnoProximo.disabled : null },
      mapaAno: ids.estMapaMes._cls.has('est-mapames-ano'),
    };
    const mapa = ids.estMapaMes;
    if (c.periodo === 'ano') {
      out.mapa = mapa.children[0].children.map((lin) => [lin.children[0]._text, lin.children[1].children.map((x) => ((/est-anodia-(\w+)/.exec(x.className) || [])[1] || '.')).join(',')]);
    } else {
      out.mapa = mapa.children.map((t) => [t.className, t.children.map((x) => x.className + '|' + x._text).join(';')]);
    }
    out.soltas = {
      streak: S.run('estStreakAtual(HIST)'), recorde: S.run('estRecorde(HIST)'),
      ao_vivo: (() => { const a = JSON.parse(S.run('JSON.stringify(estHistComHojeAoVivo(isoAtual()))')); return { n: a.length, ultimo: a.length ? a[a.length - 1] : null }; })(),
    };
    return out;
  }
  const saidas = casos.map(rodar);
  const tochas = { escala: [], escalaCompartilhar: [], cor: [] };
  for (const s of [0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 15, 20, 29, 30, 31, 45, 100]) {
    tochas.escala.push([s, S.run(`escalaTocha(${s})`)]);
    tochas.escalaCompartilhar.push([s, S.run(`escalaTochaCompartilhar(${s})`)]);
    tochas.cor.push([s, S.run(`corDoStreak(${s})`)]);
  }
  return { casos, saidas, tochas };
}
if (process.argv.includes('--est-tz')) {
  process.stdout.write(JSON.stringify(gerarEstatisticas().saidas));
  process.exit(0);
}

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

/* ---------------- loot (sorteios com a sequência de Math.random gravada) ---------------- */
{
  const S = criarSandbox();
  const lootCasos = [];
  const rl = mulberry32(777);
  for (let i = 0; i < 400; i++) {
    const modo = i % 4; // 0 sortearItem, 1 sortearItem sem lendário, 2 tesouroExtra, 3 loot do dia
    const sorte = [0, 0.25, 0.5, 0.8, 1][Math.floor(rl() * 5)];
    const tes = [0, 0, 15, 40][Math.floor(rl() * 4)], tex = [0, 0, 20, 100][Math.floor(rl() * 4)];
    const estagio = 1 + Math.floor(rl() * 4), nTarefas = Math.floor(rl() * 14);
    const gen = mulberry32(5000 + i), usados = [];
    S.ctx.__rnd = () => { const v = gen(); usados.push(v); return v; };
    S.run('Math.random = __rnd; limparVariantes();');
    S.run(`afixoSoma = (k) => k === 'tes' ? ${tes} : k === 'tex' ? ${tex} : 0; window.estagioAtual = () => ${estagio};`);
    let ids;
    if (modo === 0) ids = [S.run(`sortearItem(${sorte}, true)`)];
    else if (modo === 1) ids = [S.run(`sortearItem(${sorte}, false)`)];
    else if (modo === 2) { const r = S.run(`tesouroExtra(${sorte})`); ids = r === null ? [] : [r]; }
    else {
      ids = S.run(`(function(){ const le = lootDoEstagio(); const sorte = Math.min(1, ${nTarefas} / 10 + le.bonus); const out = [];
        for (let i = 0; i < le.qtd; i++) out.push(sortearItem(sorte, false));
        const tx = tesouroExtra(sorte); if (tx !== null) out.push(tx); return out; })()`);
    }
    const vars = S.run('exportarVariantes()');
    lootCasos.push({ modo, sorte, tes, tex, estagio, nTarefas, usados, ids, vars });
  }
  casos.loot = lootCasos;
}

/* ---------------- baú do dia, loja, forja ---------------- */
{
  const S = criarSandbox();
  const gen0 = (seed) => { const g = mulberry32(seed), usados = []; S.ctx.__rnd = () => { const v = g(); usados.push(v); return v; }; S.run('Math.random = __rnd;'); return usados; };
  const rb = mulberry32(31337);
  const bau = [];
  const DIFS_ID = ['trivial', 'facil', 'media', 'dificil'];
  for (let i = 0; i < 300; i++) {
    const nT = Math.floor(rb() * 9);
    const difs = Array.from({ length: nT }, () => DIFS_ID[Math.floor(rb() * 4)]);
    const pity = Math.floor(rb() * 8), estagio = 1 + Math.floor(rb() * 4);
    const afx = { tes: [0, 15][Math.floor(rb() * 2)], tex: [0, 30][Math.floor(rb() * 2)], bau: [0, 10][Math.floor(rb() * 2)], abu: [0, 15, 60][Math.floor(rb() * 3)] };
    S.run('limparVariantes(); inventario = [];');
    S.run(`tarefas = ${JSON.stringify(difs.map((d, k) => ({ texto: 't' + k, tipo: 'hoje', data: '2026-11-11', feitaEm: null, dif: d })))};`);
    S.run(`afixoSoma = (k) => (${JSON.stringify(afx)})[k] || 0; window.afixoSoma = afixoSoma; window.estagioAtual = () => ${estagio}; _gravarPityBau(${pity});`);
    const usados = gen0(9000 + i);
    const media = S.run('mediaDifHoje()');
    const estado = S.run("gerarEstadoBauDia('2026-11-11', tarefas.filter(ehDeHoje).length)");
    bau.push({ difs, pity, estagio, afx, usados, media, estado: JSON.parse(JSON.stringify(estado)), pityDepois: S.run('_lerPityBau()'),
      inventario: JSON.parse(JSON.stringify(S.run('inventario'))), vars: S.run('exportarVariantes()') });
  }
  casos.bauDia = bau;

  // chaveParaDestravar
  const chaves = linhas.map((r, i) => [r, i]).filter(([r]) => r[2] === 'chave').map(([, i]) => i);
  const rc = mulberry32(4242), chv = [];
  for (let i = 0; i < 120; i++) {
    const inv = Array.from({ length: Math.floor(rc() * 6) }, () => ({ id: chaves[Math.floor(rc() * chaves.length)], q: Math.floor(rc() * 3) }));
    const tier = Math.floor(rc() * 4);
    chv.push({ inv, tier, esperado: S.run(`inventario = ${JSON.stringify(inv)}; chaveParaDestravar(${tier})`) });
  }
  casos.chavesBau = chv;

  // loja
  const loja = [];
  const rlj = mulberry32(555);
  for (let i = 0; i < 120; i++) {
    const dia = 1 + Math.floor(rlj() * 28), mes = Math.floor(rlj() * 12), ano = 2026 + Math.floor(rlj() * 2);
    const sem = Math.floor(rlj() * 64), nivelAlvo = 1 + Math.floor(rlj() * 14);
    const xp = [0, 100, 260, 480, 740, 1040, 1380, 1760, 2180, 2640, 3140, 3680, 4260, 4880][nivelAlvo - 1] + 5;
    S.run(`__hoje = [${ano}, ${mes}, ${dia}]; semente = ${sem}; xpTotal = ${xp};`);
    const desc = [0, 0.05, -0.1, 0.3][Math.floor(rlj() * 4)];
    S.run(`window.descontoLoja = () => ${desc};`);
    const est = S.run('montarEstoque()');
    loja.push({ ano, mes, dia, sem, xp, nivel: S.run('progresso().nivel'), dc: S.run('diasCorridos()'), desc,
      estoque: est.map((e) => ({ id: e.id, o: e.oferta })), precos: est.map((e) => S.run(`precoLoja(${e.id}, ${e.oferta})`)) });
  }
  casos.loja = { casos: loja, nivelMinimo: Array.from({ length: 8 }, (_, r) => S.run(`nivelMinimo(${r})`)),
    pesos: Array.from({ length: 16 }, (_, n) => S.run(`pesosLojaPorNivel(${n + 1})`)) };

  // forja
  const tesouros = linhas.map((r, i) => [r, i]).filter(([r]) => r[2] === 'tesouro' && !r[8]).map(([, i]) => i);
  const rf = mulberry32(8080), fj = [];
  for (let i = 0; i < 300; i++) {
    const rar = Math.floor(rf() * 8), excl = [null, 'gan', 'est', 'sor', 'bar'][Math.floor(rf() * 5)];
    const sel = Array.from({ length: Math.floor(rf() * 4) }, () => tesouros[Math.floor(rf() * tesouros.length)]);
    const pn = S.run(`pNegForja(${JSON.stringify(sel)})`);
    const usados = gen0(12000 + i);
    const afx = S.run(`afxRolar(${rar}, ${JSON.stringify(excl)}, ${pn})`);
    fj.push({ rar, excl, sel, pn, usados, afx });
  }
  casos.forja = fj;
}
/* ---------------- conquistas V2, histórico, Grimório (Fase 3) ---------------- */
{
  const indentFn = (nome) => {
    const m = new RegExp('^[ \\t]+function ' + nome + '\\(', 'm').exec(html);
    if (!m) throw new Error('função indentada não achada: ' + nome);
    const abre = html.indexOf('{', html.indexOf(')', m.index));
    return html.slice(m.index, fimBalanceado(html, abre) + 1);
  };
  const indentDecl = (nome) => {
    const m = new RegExp('^[ \\t]+const ' + nome + '\\s*=', 'm').exec(html);
    if (!m) throw new Error('decl indentada não achada: ' + nome);
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
  };
  const iniCat = html.indexOf('const CATEGORIAS = [');
  const idFor = html.indexOf('CATEGORIAS.forEach(cat => {\n    cat.tiers.forEach((t, i) => { t.id');
  const fimFor = html.indexOf('});\n  });', idFor) + 8;
  const fonteConq = [
    indentDecl('CATEGORIAS'), html.slice(idFor, fimFor), indentDecl('IDS_CURADOS_V2'), indentDecl('CONQUISTAS_V2'),
    ...['idiomaConquistas', 'itensVistosSet', 'raridadesObtidasCount', 'melhorSequenciaDeVitorias', 'montarContexto', 'resolver'].map(indentFn),
  ].join('\n');
  void iniCat;
  const rc = mulberry32(777);
  const rI = (a, b) => a + Math.floor(rc() * (b - a + 1));
  const idGrim = S0.run("ITENS.findIndex(a => a[1] === 'Grimório')");
  const vivos = linhas.map((r, i) => [r, i]).filter(([r, i]) => i < baseN && !r[8]).map(([, i]) => i);
  const casosC = [];
  const S = criarSandbox();
  S.run(`const ID_GRIMORIO = ITENS.findIndex(a => a[1] === 'Grimório'); let HIST = []; window.obterHistorico = () => HIST.slice();`);
  S.run(fonteConq);
  casos.conquistasDefs = JSON.parse(S.run(`JSON.stringify(CONQUISTAS_V2.map(c => ({id: c.id, nome: c.nome, nome_en: c.nome_en, cor: c.cor, req: c.req, req_en: c.req_en})))`));
  casos.conquistasIds = JSON.parse(S.run('JSON.stringify(IDS_CURADOS_V2)'));
  const dias = (n) => { const d = new Date(2026, 10, 11 - n, 12); return iso(d.getFullYear(), d.getMonth() + 1, d.getDate()); };
  for (let i = 0; i < 250; i++) {
    const nh = rI(0, i % 7 === 0 ? 70 : 20);
    const res = ['vitoria', 'vitoria', 'vitoria', 'fuga', 'descanso', 'sem_tarefa'];
    let d = rI(1, 90);
    const hist = [];
    for (let k = 0; k < nh; k++) {
      hist.push({ data: dias(d), resultado: res[rI(0, 5)], monstroId: i % 11 === 0 && k === 0 ? null : rI(0, 62), tarefas: rI(0, 6) });
      d -= (rc() < 0.8 ? 1 : rI(2, 4)); if (d < 1) break;
    }
    if (i % 5 === 0) hist.reverse();
    const nVis = [0, 1, 3, 10, 25, 60, 120, 315][rI(0, 7)];
    const vistos = []; while (vistos.length < nVis) { const id = vivos[rI(0, vivos.length - 1)]; if (!vistos.includes(id)) vistos.push(id); }
    if (i % 3 === 0 && !vistos.includes(idGrim)) vistos.push(idGrim);
    if (i % 13 === 0) vistos.push(vivos[0], vivos[0]); // duplicata
    const xp = [0, 100, 260, 700, 2000, 9000, 40000, 300000][rI(0, 7)];
    const tot = [0, 1, 5, 19, 20, 49, 50, 400][rI(0, 7)];
    const venceu = i % 2 === 0;
    S.run(`HIST = ${JSON.stringify(hist)}; xpTotal = ${xp}; __total = ${tot}; derrotadoEm = ${venceu ? "'2026-11-11'" : 'null'};`);
    S.run(`localStorage.setItem(chaveConta('questlog.itensVistos.v1'), ${JSON.stringify(JSON.stringify(vistos))});`);
    const ctx = JSON.parse(S.run('JSON.stringify(montarContexto(true))'));
    const ctxSem = JSON.parse(S.run('JSON.stringify(montarContexto(false))'));
    const resolvidas = JSON.parse(S.run(`JSON.stringify(CONQUISTAS_V2.map(c => { const ctx = montarContexto(true); return {id: c.id, meta: resolver(c.meta, ctx), valor: c.valor(ctx), req: resolver(c.req, ctx), req_en: resolver(c.req_en, ctx)}; }))`));
    const idxHoje = S.run('MONSTROS.indexOf(monstroDoDia())');
    casosC.push({ hist, vistos, xp, total: tot, venceu, idxHoje, nivel: S.run('progresso().nivel'), ctx, ctxSem, resolvidas, seq: S.run(`melhorSequenciaDeVitorias(HIST)`) });
  }
  casos.conquistas = casosC;
  casos.grimorio = { idGrimorio: idGrim, niveis: [0, 1, 2, 3, 4, 5, 6, 7, 63, 17].map((s) => ({ s, nivel: 4 + (s % 4) })) };
}
// Estatísticas: gera no fuso atual e confere que o JS dá o MESMO resultado em outros fusos (sequência e mapas dependem de datas)
{
  const est = gerarEstatisticas();
  const ref = JSON.stringify(est.saidas);
  const tzs = ['UTC', 'Asia/Tokyo', 'Pacific/Auckland', 'America/St_Johns', 'Pacific/Kiritimati', 'Pacific/Pago_Pago', 'Europe/Lisbon', 'America/New_York', 'Asia/Kolkata'];
  for (const tz of tzs) {
    const o = execFileSync(process.execPath, [fileURLToPath(import.meta.url), '--est-tz'], { env: { ...process.env, TZ: tz }, maxBuffer: 1 << 29 }).toString();
    if (o !== ref) throw new Error('estatísticas: o JS dá resultado diferente no fuso ' + tz);
  }
  casos.estatisticas = { casos: est.casos, saidas: est.saidas, tochas: est.tochas, fusosConferidos: tzs };
}
const fusos = ['America/Sao_Paulo', 'UTC', 'Asia/Tokyo', 'Europe/Lisbon', 'America/New_York', 'Pacific/Auckland', 'Asia/Kolkata', 'America/St_Johns'];
casos.fusos = fusos.map((tz) => ({ tz, datas: JSON.parse(execFileSync(process.execPath, [fileURLToPath(import.meta.url), '--tz'], { env: { ...process.env, TZ: tz }, maxBuffer: 1 << 28 }).toString()) }));
casos.temasArena = S0.run('TEMAS_ARENA.map(t => t.id)');
casos.nMonstros = S0.run('MONSTROS.length');

// Entrada: idioma padrão do aparelho (script do <head>) e posição do cartão do tour (tourPosicionar), rodados do index.html
{
  const iniI = html.lastIndexOf('(function(){', html.indexOf("if (localStorage.getItem('questlog.idioma.v1')) return; // ja escolhido"));
  const fimI = html.indexOf('})();', iniI) + 5;
  const fonteIdioma = html.slice(iniI, fimI);
  const idiomaJs = (langs) => {
    const mem = {};
    const ctx = vm.createContext({ navigator: { languages: langs, language: langs[0] || '' }, localStorage: { getItem: (k) => (k in mem ? mem[k] : null), setItem: (k, v) => { mem[k] = String(v); } } });
    vm.runInContext(fonteIdioma, ctx);
    return mem['questlog.idioma.v1'];
  };
  const listas = [['pt-BR'], ['pt'], ['PT-br'], ['pt-PT'], ['en-US'], ['en-US', 'pt-BR'], ['fr', 'es', 'pt-BR'], ['pt-PT', 'pt-BR'], ['es-419'], ['de'], ['pt-br', 'en'], ['ptbr'], ['zh-CN', 'en-GB'], ['pt-PT', 'en'], []];
  const idioma = listas.map((l) => ({ langs: l, idioma: l.length ? idiomaJs(l) : 'en' }));
  // listas vazias: o navegador usa navigator.language ('' aqui) -> en
  const iniT = html.indexOf('const largo = W > 700, cw = largo');
  const fimT = html.indexOf("card.classList.toggle('noTopo'", iniT);
  const fonteTour = 'function posTour(W, H, r, pad, card){ ' + html.slice(iniT, fimT) + ' return {nl, nt, bot, largo, cw}; }';
  const ctxT = vm.createContext({ Math });
  vm.runInContext(fonteTour, ctxT);
  const rc2 = mulberry32(4242);
  const rn = (a, b) => a + Math.floor(rc2() * (b - a + 1));
  const cartao = [];
  const larguras = [320, 360, 375, 390, 412, 600, 700, 701, 800, 1024];
  for (let i = 0; i < 400; i++) {
    const W = larguras[rn(0, larguras.length - 1)], H = rn(480, 960), ch = rn(110, 280);
    const nr = rn(1, 2);
    const rects = [];
    for (let k = 0; k < nr; k++) { const w = rn(20, Math.min(W - 10, 360)), h = rn(20, 200); const left = rn(0, W - w), top = rn(0, H - h); rects.push({ left, top, right: left + w, bottom: top + h }); }
    const l = Math.min(...rects.map((q) => q.left)), t = Math.min(...rects.map((q) => q.top)), r2 = Math.max(...rects.map((q) => q.right)), b = Math.max(...rects.map((q) => q.bottom));
    const r = { rects, left: l, top: t, right: r2, bottom: b, width: r2 - l, height: b - t };
    const card = { style: {}, offsetHeight: ch };
    const o = ctxT.posTour(W, H, r, 6, card);
    cartao.push({ W, H, ch, rects, r: { left: l, top: t, right: r2, bottom: b }, saida: { nl: o.nl, nt: o.nt, bot: o.bot, largo: o.largo, cw: o.cw } });
  }
  casos.entrada = { idioma, cartao };
}
const dest = path.join(raiz, 'app-flutter', 'test', 'fixtures', 'casos_js.json');
fs.mkdirSync(path.dirname(dest), { recursive: true });
fs.writeFileSync(dest, JSON.stringify(casos));
console.log('gravado', dest, (fs.statSync(dest).size / 1024).toFixed(0) + ' KB', 'virada=' + casos.virada.length, 'fusos=' + casos.fusos.length);
