// Extrai os SVG de Configurações/Perfil do index.html e gera lib/ui/svg_dados.dart
const fs = require('fs');
const html = fs.readFileSync('C:/Users/User/dungeonlog-repo/play/index.html', 'utf8').split('\r\n').join('\n');
function svgDe(idMarcador, nth = 0, dentroDe = 'svg') {
  const i = html.indexOf(idMarcador);
  if (i < 0) throw new Error('marcador não achado: ' + idMarcador);
  let p = i;
  for (let k = 0; k <= nth; k++) { p = html.indexOf('<svg', p + (k ? 4 : 0)); }
  const f = html.indexOf('</svg>', p) + 6;
  return html.slice(p, f);
}
const itens = {
  engrenagem: svgDe('id="perfilCfgBtn"'),
  voltar: svgDe('id="cfgVoltarBtn"'),
  seta: svgDe('id="cfgAbrirConta"', 1),
  conta: svgDe('id="cfgAbrirConta"', 0),
  herois: svgDe('id="cfgAbrirHerois"', 0),
  aparencia: svgDe('id="cfgAbrirAparencia"', 0),
  prefs: svgDe('id="cfgAbrirPrefs"', 0),
  rever: svgDe('id="cfgRever"', 0),
  privacidade: svgDe('id="cfgLinkPrivacidade"', 0),
  termos: svgDe('id="cfgLinkTermos"', 0),
  externo: svgDe('id="cfgLinkPrivacidade"', 1),
  idioma: svgDe('id="cfgAbrirIdioma"', 0),
  feedback: svgDe('id="cfgRowFeedback"', 0),
  som: svgDe('id="cfgRowSom"', 0),
  crt: svgDe('id="cfgRowCrt"', 0),
  golpes: svgDe('id="cfgRowGolpes"', 0),
  notif: svgDe('id="cfgRowNotif"', 0),
  assinatura: svgDe('id="cfgAbrirAssinatura"', 0),
  sair: svgDe('id="cfgSairBtn"', 0),
  excluir: svgDe('id="excluirContaBtn"', 0),
  editar: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 013 3L7 19l-4 1 1-4z"/></svg>',
  check: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>',
  checkTema: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5 9-10"/></svg>',
  // ícones das conquistas (CATEGORIAS[].icone): conteúdo interno do svg de 24x24
  conqSequencia: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22c4 0 7-2.7 7-6.8 0-3-2-5-3.3-7.2-.3 1.6-1.2 2.7-2.2 2.7-1.4 0-1.3-2-1.5-3.2C11.4 5.4 9 3 9 3c.6 3-1.4 4.6-2.7 6.7C5.2 11.5 5 13.2 5 15.2 5 19.3 8 22 12 22z"/></svg>',
  conqMonstros: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 3h12l3 5-9 13L3 8z"/><path d="M3 8h18"/><path d="M9 3l3 5 3-5"/></svg>',
  conqNivel: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.5l2.9 6.6 7.1.7-5.4 4.8 1.6 7-6.2-3.8-6.2 3.8 1.6-7-5.4-4.8 7.1-.7z"/></svg>',
  conqTarefas: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>',
  conqItens: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5C4 4.1 5.6 3 7.5 3H12v17H7.5C5.6 20 4 19.4 4 18V5.5z"/><path d="M20 5.5C20 4.1 18.4 3 16.5 3H12v17h4.5c1.9 0 3.5-.6 3.5-2V5.5z"/></svg>',
};
let saida = '// GERADO por tools (extração dos SVG de play/index.html). Não editar à mão.\n// Cada valor é o <svg> inteiro; a cor vem de `currentColor`.\nconst Map<String, String> svgDados = {\n';
for (const [k, v] of Object.entries(itens)) {
  const limpo = v.replace(/\s+/g, ' ').replace(/ >/g, '>').replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" ');
  saida += `  '${k}': '${limpo.replace(/'/g, "\\'")}',\n`;
}
saida += '};\n';
fs.writeFileSync('C:/Users/User/dungeonlog-repo/app-flutter/lib/ui/svg_dados.dart', saida);
console.log(Object.keys(itens).length, 'svgs');
