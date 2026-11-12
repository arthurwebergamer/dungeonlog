// Gera os efeitos sonoros do app (WAV mono 22050 Hz) a partir das mesmas "receitas" do original
// (play/index.html, bloco SFX: tom/ruido/ruidoFaixa/tinir e o catálogo SONS). Rodar: node app-flutter/tools/gerar_sons.mjs
// O volume (padrão 0,55 no original) NÃO vai gravado: o app aplica na hora de tocar.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const dest = path.resolve(aqui, '..', 'assets', 'sons');
fs.mkdirSync(dest, { recursive: true });
const SR = 22050;

function mulberry32(a) { return () => { a |= 0; a = (a + 0x6D2B79F5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }

class Cena {
  constructor() { this.amostras = new Float32Array(SR * 2); this.fim = 0; this.rnd = mulberry32(12345); }
  _soma(inicio, dados) {
    const i0 = Math.floor(inicio * SR);
    for (let i = 0; i < dados.length; i++) if (i0 + i < this.amostras.length) this.amostras[i0 + i] += dados[i];
    this.fim = Math.max(this.fim, Math.min(this.amostras.length, i0 + dados.length));
  }
  tom({ freq, tipo = 'sine', inicio = 0, duracao = 0.15, ganho = 1, freqFinal = null }) {
    const n = Math.floor((duracao + 0.02) * SR), d = new Float32Array(n);
    let fase = 0;
    for (let i = 0; i < n; i++) {
      const t = i / SR;
      const f = freqFinal !== null && t < duracao ? freq * Math.pow(Math.max(1, freqFinal) / freq, t / duracao) : (freqFinal !== null ? Math.max(1, freqFinal) : freq);
      fase += f / SR;
      const x = fase - Math.floor(fase);
      let v;
      if (tipo === 'square') v = x < 0.5 ? 1 : -1;
      else if (tipo === 'sawtooth') v = 2 * x - 1;
      else if (tipo === 'triangle') v = 1 - 4 * Math.abs(x - 0.5);
      else v = Math.sin(2 * Math.PI * x);
      let g;
      if (t < 0.008) g = ganho * (t / 0.008);
      else if (t < duracao) g = ganho * Math.pow(0.001 / ganho, (t - 0.008) / (duracao - 0.008));
      else g = 0;
      d[i] = v * g;
    }
    this._soma(inicio, d);
  }
  _ruidoBruto(duracao, curva) {
    const n = Math.max(1, Math.floor(SR * duracao)), d = new Float32Array(n);
    for (let i = 0; i < n; i++) d[i] = (this.rnd() * 2 - 1) * Math.pow(1 - i / n, curva);
    return d;
  }
  _envelope(d, ganho, duracao) {
    for (let i = 0; i < d.length; i++) {
      const t = i / SR;
      d[i] *= t < duracao ? ganho * Math.pow(0.001 / ganho, t / duracao) : 0;
    }
  }
  _biquad(d, tipo, freq, q) {
    const w0 = 2 * Math.PI * freq / SR, alfa = Math.sin(w0) / (2 * q), c = Math.cos(w0);
    let b0, b1, b2;
    if (tipo === 'highpass') { b0 = (1 + c) / 2; b1 = -(1 + c); b2 = (1 + c) / 2; } else { b0 = alfa; b1 = 0; b2 = -alfa; }
    const a0 = 1 + alfa, a1 = -2 * c, a2 = 1 - alfa;
    let x1 = 0, x2 = 0, y1 = 0, y2 = 0;
    const o = new Float32Array(d.length);
    for (let i = 0; i < d.length; i++) {
      const y = (b0 / a0) * d[i] + (b1 / a0) * x1 + (b2 / a0) * x2 - (a1 / a0) * y1 - (a2 / a0) * y2;
      x2 = x1; x1 = d[i]; y2 = y1; y1 = y; o[i] = y;
    }
    return o;
  }
  ruido({ inicio = 0, duracao = 0.08, ganho = 0.5, passaAlta = null }) {
    let d = this._ruidoBruto(duracao, 1);
    if (passaAlta) d = this._biquad(d, 'highpass', passaAlta, Math.SQRT1_2);
    this._envelope(d, ganho, duracao);
    this._soma(inicio, d);
  }
  ruidoFaixa({ inicio = 0, duracao = 0.1, ganho = 0.4, freq = 1000, q = 1 }) {
    let d = this._ruidoBruto(duracao, 1.5);
    d = this._biquad(d, 'bandpass', freq, q);
    this._envelope(d, ganho, duracao);
    this._soma(inicio, d);
  }
  tinir(freqs, inicio, ganho, dur) {
    freqs.forEach((f, i) => this.tom({ freq: f, inicio, duracao: dur * (1 - i * 0.2), ganho: ganho / (i + 1) }));
    this.ruidoFaixa({ inicio, duracao: 0.015, ganho, freq: freqs[0], q: 2 });
  }
  wav() {
    const n = this.fim, pcm = Buffer.alloc(44 + n * 2);
    pcm.write('RIFF', 0); pcm.writeUInt32LE(36 + n * 2, 4); pcm.write('WAVEfmt ', 8); pcm.writeUInt32LE(16, 16);
    pcm.writeUInt16LE(1, 20); pcm.writeUInt16LE(1, 22); pcm.writeUInt32LE(SR, 24); pcm.writeUInt32LE(SR * 2, 28);
    pcm.writeUInt16LE(2, 32); pcm.writeUInt16LE(16, 34); pcm.write('data', 36); pcm.writeUInt32LE(n * 2, 40);
    for (let i = 0; i < n; i++) pcm.writeInt16LE(Math.round(Math.max(-1, Math.min(1, this.amostras[i])) * 32767), 44 + i * 2);
    return pcm;
  }
}

const SONS = {
  golpe: (c) => { c.ruido({ duracao: 0.06, ganho: 0.6 }); c.tom({ freq: 180, freqFinal: 70, tipo: 'square', duracao: 0.09, ganho: 0.5 }); },
  danoHeroi: (c) => c.tom({ freq: 220, freqFinal: 90, tipo: 'sawtooth', duracao: 0.22, ganho: 0.55 }),
  fuga: (c) => c.tom({ freq: 520, freqFinal: 110, tipo: 'sawtooth', duracao: 0.4, ganho: 0.4 }),
  levelup: (c) => [523, 659, 784, 1047].forEach((f, i) => c.tom({ freq: f, tipo: 'sine', inicio: i * 0.07, duracao: 0.18, ganho: 0.25 })),
  loot: (c) => [880, 1175, 1568].forEach((f, i) => c.tom({ freq: f, tipo: 'sine', inicio: i * 0.05, duracao: 0.3, ganho: 0.35 })),
  morte: (c) => c.tom({ freq: 160, freqFinal: 50, tipo: 'sawtooth', duracao: 0.5, ganho: 0.55 }),
  tarefa: (c) => c.tom({ freq: 440, freqFinal: 660, tipo: 'triangle', duracao: 0.1, ganho: 0.3 }),
  compra: (c) => {
    for (let i = 0; i < 4; i++) c.tinir([3100 - i * 170, 4600], i * 0.05, 0.17, 0.07);
    c.tom({ freq: 392, tipo: 'triangle', inicio: 0.25, duracao: 0.18, ganho: 0.25 });
    c.tom({ freq: 523, tipo: 'triangle', inicio: 0.25, duracao: 0.18, ganho: 0.2 });
    c.tom({ freq: 587, tipo: 'triangle', inicio: 0.4, duracao: 0.35, ganho: 0.25 });
    c.tom({ freq: 784, tipo: 'triangle', inicio: 0.4, duracao: 0.35, ganho: 0.2 });
  },
  semMoedas: (c) => {
    c.tom({ freq: 90, freqFinal: 50, tipo: 'sine', duracao: 0.1, ganho: 0.5 });
    c.ruidoFaixa({ duracao: 0.04, ganho: 0.7, freq: 2500, q: 2 });
    c.tinir([1480, 2290, 3500, 5100], 0, 0.4, 0.7);
    c.tinir([1480, 2290, 3500], 0.18, 0.16, 0.4);
  },
  bauTrancado: (c) => {
    for (let i = 0; i < 2; i++) {
      c.tom({ freq: 90, freqFinal: 55, tipo: 'square', inicio: i * 0.14, duracao: 0.09, ganho: 0.45 });
      c.ruidoFaixa({ inicio: i * 0.14, duracao: 0.05, ganho: 0.6, freq: 900, q: 2 });
    }
    c.tinir([1400, 2100], 0.06, 0.1, 0.12);
  },
  venda: (c) => {
    c.ruidoFaixa({ inicio: 0, duracao: 0.22, ganho: 0.5, freq: 900, q: 1.2 });
    c.ruidoFaixa({ inicio: 0.02, duracao: 0.15, ganho: 0.35, freq: 2200, q: 3 });
    for (let i = 0; i < 5; i++) c.tinir([2600 + i * 180, 3900], 0.06 + i * 0.05, 0.16, 0.07);
    c.tom({ freq: 110, freqFinal: 70, tipo: 'sine', inicio: 0.3, duracao: 0.12, ganho: 0.3 });
  },
  investir: (c) => { c.tom({ freq: 440, tipo: 'triangle', duracao: 0.05, ganho: 0.25 }); c.tom({ freq: 660, tipo: 'triangle', inicio: 0.05, duracao: 0.09, ganho: 0.3 }); },
  equipar: (c) => {
    c.tom({ freq: 300, freqFinal: 700, tipo: 'triangle', duracao: 0.12, ganho: 0.3 });
    c.ruido({ inicio: 0.11, duracao: 0.03, ganho: 0.5 });
    c.tom({ freq: 200, tipo: 'square', inicio: 0.11, duracao: 0.05, ganho: 0.36 });
  },
  desequipar: (c) => c.tom({ freq: 220, freqFinal: 140, tipo: 'triangle', duracao: 0.09, ganho: 0.3 }),
  usar: (c) => c.tom({ freq: 500, freqFinal: 750, tipo: 'sine', duracao: 0.14, ganho: 0.3 }),
  abrirGrimorio: (c) => { c.ruido({ duracao: 0.12, ganho: 0.18 }); c.tom({ freq: 700, freqFinal: 1000, tipo: 'sine', duracao: 0.16, ganho: 0.22 }); },
  grimorio: (c) => [392, 466, 587, 698, 932].forEach((f, i) => c.tom({ freq: f, tipo: 'sine', inicio: i * 0.09, duracao: 0.28, ganho: 0.28 })),
  chegadaRecompensa: (c) => { c.tom({ freq: 1046, tipo: 'sine', duracao: 0.22, ganho: 0.32 }); c.tom({ freq: 1568, tipo: 'sine', inicio: 0.02, duracao: 0.28, ganho: 0.18 }); },
  poofBau: (c) => { c.ruido({ duracao: 0.05, ganho: 0.36 }); c.tom({ freq: 300, freqFinal: 600, tipo: 'triangle', duracao: 0.06, ganho: 0.22 }); },
  estagioNovo: (c) => {
    c.ruido({ duracao: 0.06, ganho: 0.3, passaAlta: 800 });
    c.tom({ freq: 440, freqFinal: 660, tipo: 'triangle', duracao: 0.28, ganho: 0.26 });
    c.tom({ freq: 660, freqFinal: 990, tipo: 'sine', inicio: 0.03, duracao: 0.26, ganho: 0.18 });
  },
  erro: (c) => c.tom({ freq: 200, freqFinal: 130, tipo: 'triangle', duracao: 0.14, ganho: 0.3 }),
  roletaFim: (c) => {
    c.tom({ freq: 130, freqFinal: 60, tipo: 'sine', duracao: 0.16, ganho: 0.34 });
    c.tom({ freq: 523, tipo: 'triangle', duracao: 0.14, ganho: 0.26 });
    c.tom({ freq: 784, tipo: 'triangle', inicio: 0.09, duracao: 0.16, ganho: 0.26 });
    c.tom({ freq: 1046, tipo: 'sine', inicio: 0.18, duracao: 0.4, ganho: 0.28 });
    c.tom({ freq: 1568, tipo: 'sine', inicio: 0.2, duracao: 0.34, ganho: 0.14 });
  },
};
// tique da roleta: o tom sobe com o progresso (0 a 1); 6 degraus
for (let k = 0; k <= 5; k++) SONS['roletaTick' + k] = (c) => c.tom({ freq: 520 + (k / 5) * 420, tipo: 'square', duracao: 0.022, ganho: 0.1 });

let total = 0;
for (const [nome, fn] of Object.entries(SONS)) {
  const c = new Cena();
  fn(c);
  const buf = c.wav();
  fs.writeFileSync(path.join(dest, nome + '.wav'), buf);
  total += buf.length;
}
console.log(Object.keys(SONS).length + ' sons,', (total / 1024).toFixed(0) + ' KB em', dest);
