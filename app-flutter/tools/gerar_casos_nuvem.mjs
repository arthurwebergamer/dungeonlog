// Gera app-flutter/test/fixtures/casos_nuvem_js.json: o que o código de NUVEM do app HTML faz de verdade
// (puxarNuvem, empurrarNuvem, guardarHistorico, guardarBackupLocal, lerSalvoEm, marcarSujo/temSujo), para o Dart
// (lib/dominio/nuvem.dart + lib/dados/sincronizador_nuvem.dart) ser comparado em test/nuvem_paridade_test.dart.
//
// As funções NÃO são reescritas: o texto delas é recortado de play/index.html (ficam dentro de iniciarFirebase(),
// indentadas) e executado num sandbox (vm) do Node, com localStorage e Firestore (doc/getDoc/setDoc) falsos.
//
// Uso (raiz do repositório):  node app-flutter/tools/gerar_casos_nuvem.mjs
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raiz = path.resolve(aqui, '..', '..');
const html = fs.readFileSync(path.join(raiz, 'play', 'index.html'), 'utf8').split('\r\n').join('\n');

function fimBalanceado(src, abre) {
  const par = { '{': '}', '[': ']', '(': ')' };
  const pilha = [];
  let aspas = null, esc = false;
  for (let i = abre; i < src.length; i++) {
    const c = src[i], n = src[i + 1];
    if (aspas) { if (esc) esc = false; else if (c === '\\') esc = true; else if (c === aspas) aspas = null; continue; }
    if (c === '/' && n === '/') { i = src.indexOf('\n', i); if (i < 0) break; continue; }
    if (c === '/' && n === '*') { i = src.indexOf('*/', i) + 1; continue; }
    if (c === '\'' || c === '"' || c === '`') { aspas = c; continue; }
    if (par[c]) pilha.push(par[c]);
    else if (c === pilha[pilha.length - 1]) { pilha.pop(); if (!pilha.length) return i; }
  }
  throw new Error('sem fecho');
}
// função com qualquer indentação (as de nuvem são internas a iniciarFirebase); exige UMA definição só
function fonte(nome) {
  const re = new RegExp('^[ \\t]*(?:async )?function ' + nome + '\\(', 'gm');
  const achados = [...html.matchAll(re)];
  if (achados.length !== 1) throw new Error(`função ${nome}: esperava 1 definição, achei ${achados.length}`);
  const m = achados[0];
  const abre = html.indexOf('{', html.indexOf(')', m.index));
  return html.slice(m.index, fimBalanceado(html, abre) + 1);
}
function linha(re) {
  const m = re.exec(html);
  if (!m) throw new Error('linha não achada: ' + re);
  return m[0];
}
function decl(nome) { // const NOME = [ ... ];  (nível zero)
  const m = new RegExp('^const ' + nome + '\\s*=', 'm').exec(html);
  if (!m) throw new Error('declaração não achada: ' + nome);
  const abre = html.indexOf('[', m.index);
  return html.slice(m.index, fimBalanceado(html, abre) + 1) + ';';
}

const FONTES = [
  decl('CHAVES_SECUNDARIAS_CONTA'),
  fonte('chaveSaveAtual'), fonte('chaveConta'),
  fonte('lerSalvoEm'), fonte('guardarBackupLocal'), fonte('guardarHistorico'),
  fonte('puxarNuvem'), fonte('marcarSujo'), fonte('temSujo'), fonte('empurrarNuvem'),
  linha(/^[ \t]*let _seqSalvar = 0;/m).trim(),
  linha(/^[ \t]*const chaveSujo = uid => [^\n]+;/m).trim(),
];

const AGORA = 1763800000000; // ms fixo (nov/2025)
const UID = 'U';

function sandbox({ local = {}, nuvem = {}, agora = AGORA, pj = 'pj1' }) {
  const store = new Map(Object.entries(local));
  const localStorage = {
    getItem: (k) => (store.has(k) ? store.get(k) : null),
    setItem: (k, v) => { store.set(k, String(v)); },
    removeItem: (k) => { store.delete(k); },
  };
  const docs = new Map(Object.entries(nuvem).map(([k, v]) => [k, JSON.parse(JSON.stringify(v))]));
  const escritas = [];
  const window = { EH_DEV: false };
  const ctx = vm.createContext({
    console: { log() {}, warn() {}, error() {} }, JSON, Object, Number, String, Math, Promise, Array, Date,
    localStorage, window,
    db: {}, doc: (db, ...p) => p.join('/'),
    getDoc: async (ref) => ({ exists: () => docs.has(ref), data: () => JSON.parse(JSON.stringify(docs.get(ref))) }),
    setDoc: async (ref, obj) => { const c = JSON.parse(JSON.stringify(obj)); escritas.push([ref, c]); docs.set(ref, c); },
    puxarEntitlement: () => {},
  });
  const run = (c) => vm.runInContext(c, ctx);
  run(`Date.now = () => ${agora};`);
  run(`var _uidAtivo = ${JSON.stringify(UID)}, _personagemAtivo = ${JSON.stringify(pj)};`);
  for (const f of FONTES) run(f);
  run('window.CHAVES_SECUNDARIAS_CONTA = CHAVES_SECUNDARIAS_CONTA; window.chaveSaveAtual = chaveSaveAtual; window.chaveConta = chaveConta;');
  return { run, store, docs, escritas, ctx };
}

const save = (t, xp, comecou = true) => {
  const o = { versao: 3, tarefas: [{ texto: 'x' + xp, tipo: 'hoje', data: '2026-01-01', feitaEm: null, dif: 'media', meta: 1 }], inventario: [], variantes: [], afixos: 2,
    equipado: { arma: null, armadura: null, elmo: null, escudo: null, acess: null }, xpTotal: xp, moedas: 0, derrotadoEm: null, nomeHeroi: 'H', heroi: 0, semente: 3 };
  if (t !== null) o.salvoEm = t;
  o.comecou = comecou;
  return JSON.stringify(o);
};

const T = 1763700000000;
const LOCAIS = {
  nenhum: null,
  invalido: '{quebrado',
  naoComecado: save(T, 10, false),
  A: save(T, 100),
  semCarimbo: save(null, 50),
};
const NUVENS = {
  semDoc: undefined,
  dataVazio: '',
  invalido: '{quebrado',
  naoComecado: save(T + 9000, 10, false),
  igualA: 'IGUAL',            // = o texto local
  maisNova10s: save(T + 10000, 120),
  maisNova1s: save(T + 1000, 90),      // dentro da folga de 2 s
  maisVelha3s: save(T - 3000, 300),    // local mais novo por mais de 2 s
  maisVelha1s: save(T - 1000, 300),    // local mais novo, mas dentro da folga
  semCarimbo: save(null, 400),
};
const extrasNuvem = {
  'questlog.vida.v1': '{"vida":30,"ultimoDia":"2026-01-02"}',
  'questlog.hist.v1': '[{"data":"2026-01-02","resultado":"vitoria","monstroId":1,"tarefas":1}]',
  'questlog.dia.v1': '5',
  'questlog.trial.v1': '{"inicio":1}',
  'questlog.naoListada.v1': 'x',
};
const extrasLocal = {
  'questlog.vida.v1': '{"vida":12,"ultimoDia":"2026-01-03"}',
  'questlog.hist.v1': '[{"data":"2026-01-01","resultado":"fuga","monstroId":2,"tarefas":2}]',
  'questlog.dia.v1': '2',
  'questlog.atrib.v1': '{"forca":1}',
};
const kSave = `questlog.v1.uid.${UID}.pj.pj1`;
const kc = (b) => `${b}.uid.${UID}.pj.pj1`;

const casos = [];
for (const [nl, vl] of Object.entries(LOCAIS)) {
  for (const [nn, vn0] of Object.entries(NUVENS)) {
    if (nn === 'igualA' && vl === null) continue;
    for (const sujo of [false, true]) {
      for (const comExtras of [false, true]) {
        const vn = nn === 'igualA' ? vl : vn0;
        const local = {};
        if (vl !== null) local[kSave] = vl;
        for (const [k, v] of Object.entries(extrasLocal)) local[kc(k)] = v;
        if (sujo) local['questlog.sujo.v1.uid.' + UID] = String(T);
        const nuvem = {};
        if (vn !== undefined) nuvem['saves/' + UID] = { data: vn, ...(comExtras ? { extras: extrasNuvem } : {}), atualizadoEm: T };
        const s = sandbox({ local, nuvem });
        await s.run(`puxarNuvem(${JSON.stringify(UID)})`);
        await new Promise((r) => setImmediate(r)); // o guardarHistorico sem await do empurrarNuvem termina
        const docFinal = s.docs.get('saves/' + UID);
        const histDocs = s.escritas.filter(([r]) => r.startsWith(`saves/${UID}/historico/`));
        const empurrou = s.escritas.find(([r]) => r === 'saves/' + UID);
        casos.push({
          local: nl, nuvem: nn, sujo, comExtras,
          entrada: { local: vl, nuvem: vn === undefined ? null : { data: vn, extras: comExtras ? extrasNuvem : null } },
          saida: {
            localSave: s.store.get(kSave) ?? null,
            localExtras: Object.fromEntries(['questlog.vida.v1', 'questlog.hist.v1', 'questlog.dia.v1', 'questlog.trial.v1', 'questlog.atrib.v1', 'questlog.naoListada.v1'].map((k) => [k, s.store.get(kc(k)) ?? null])),
            backups: JSON.parse(s.store.get('questlog.backupLocal.v1.uid.' + UID) || '[]').map((b) => b.data),
            empurrou: empurrou ? { data: empurrou[1].data, extras: empurrou[1].extras } : null,
            nuvemData: docFinal ? docFinal.data : null,
            historicoComNuvemAntiga: vn !== undefined && histDocs.some(([, o]) => o.data === vn),
            sujoDepois: s.store.has('questlog.sujo.v1.uid.' + UID),
          },
        });
      }
    }
  }
}

// lerSalvoEm isolada
const textos = [null, '', '{', '{"salvoEm":123}', '{"salvoEm":"9"}', '{"salvoEm":0}', '{"x":1}', '[1]', '{"salvoEm":1.7}', save(T, 1)];
const S = sandbox({});
const lerSalvoEm = textos.map((t) => ({ entrada: t, saida: S.run(`lerSalvoEm(${JSON.stringify(t)})`) }));

// guardarHistorico isolada: quais docs grava e como ficam os marcadores
const historico = [];
const D = 86400000;
for (const [ultH, ultD, n, agora, forcar] of [
  [0, 0, 0, AGORA, false], [AGORA - 60000, AGORA - 60000, 3, AGORA, false], [AGORA - 31 * 60000, AGORA - 60000, 5, AGORA, false],
  [AGORA - 60000, AGORA - D, 2, AGORA, false], [AGORA - 60000, AGORA - 60000, 7, AGORA, true], [AGORA - 29 * 60000, AGORA - 2 * D, 6, AGORA + 5 * D, false],
  [AGORA, AGORA, 0, AGORA + 30 * 60000, false],
]) {
  const kb = 'questlog.histNuvem.v1.uid.' + UID;
  const local = {};
  if (ultH) local[kb + '.h'] = String(ultH);
  if (ultD) local[kb + '.d'] = String(ultD);
  if (n) local[kb + '.n'] = String(n);
  const s = sandbox({ local, agora });
  await s.run(`guardarHistorico(${JSON.stringify(UID)}, 'DADOS', {a:'1'}, ${forcar})`);
  historico.push({ ultH, ultD, n, agora, forcar,
    ids: s.escritas.map(([r]) => r.split('/').pop()),
    marcadores: { h: s.store.get(kb + '.h') ?? null, d: s.store.get(kb + '.d') ?? null, n: s.store.get(kb + '.n') ?? null } });
}

const dest = path.join(raiz, 'app-flutter', 'test', 'fixtures', 'casos_nuvem_js.json');
fs.writeFileSync(dest, JSON.stringify({ geradoCom: { node: process.version }, agora: AGORA, uid: UID, chavesSecundarias: vm.runInContext('CHAVES_SECUNDARIAS_CONTA', sandbox({}).ctx), casos, lerSalvoEm, historico }, null, 1));
console.log(`ok: ${casos.length} casos de puxarNuvem, ${lerSalvoEm.length} de lerSalvoEm, ${historico.length} de guardarHistorico -> ${path.relative(raiz, dest)}`);
