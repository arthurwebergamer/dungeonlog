// Extrai de play/index.html e play/style.css as imagens da entrada (splash, quiz de categoria, cortes do slide "É rápido assim").
// Uso (raiz do repositório):  node app-flutter/tools/extrair_assets_entrada.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raiz = path.resolve(aqui, '..', '..');
const html = fs.readFileSync(path.join(raiz, 'play', 'index.html'), 'utf8');
const css = fs.readFileSync(path.join(raiz, 'play', 'style.css'), 'utf8');
const dest = path.join(raiz, 'app-flutter', 'assets', 'img', 'ui');
fs.mkdirSync(dest, { recursive: true });
const grava = (nome, b64) => { fs.writeFileSync(path.join(dest, nome), Buffer.from(b64, 'base64')); console.log(nome, b64.length); };

// 1) herói correndo da abertura (#bootSplash)
const sp = html.match(/<div id="bootSplash"><div class="bsPalco"><img src="data:image\/png;base64,([^"]+)"/);
grava('splash_heroi.png', sp[1]);

// 2) ícones do quiz de categoria (CATEGORIAS_ONBOARDING)
const ini = html.indexOf('const CATEGORIAS_ONBOARDING');
const bloco = html.slice(ini, html.indexOf('];', ini));
for (const id of ['estudos', 'trabalho', 'rotina', 'tudo']) {
  const m = new RegExp("id:'" + id + "'[\\s\\S]*?base64,([A-Za-z0-9+/=]+)").exec(bloco);
  grava('onb_' + id + '.png', m[1]);
}

// 3) cortes (576x64, 9 quadros) por raridade
for (const r of ['comum', 'incomum', 'raro', 'epico', 'lendario']) {
  const m = new RegExp('--spr-slash-' + r + ': url\\("data:image/png;base64,([A-Za-z0-9+/=]+)"').exec(css);
  grava('slash_' + r + '.png', m[1]);
}
