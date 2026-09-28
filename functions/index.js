/* =============================================================================
   DungeonLog -- Cloud Functions (notificacoes push)

   Pedido do usuario: push de verdade (chega com o app fechado) pra 3
   situacoes: teste gratis acabando, streak em risco de quebrar, e o
   monstro do dia ainda vivo perto da virada do dia. So funciona pra
   contas que ativaram notificacao no app (window.ativarNotificacaoPush(),
   play/index.html) -- token salvo em fcmTokens/{uid}.

   Le o estado de cada jogador em saves/{uid}.extras (mesmo doc que
   empurrarNuvem()/puxarNuvem() ja sincronizam, play/index.html) -- as
   chaves relevantes sao 'questlog.trial.v1', 'questlog.hpMonstro.v1' e
   'questlog.hist.v1' (JSON serializado como string dentro de `extras`,
   exatamente como localStorage guarda no client).

   Dedupe (nao mandar a mesma notificacao 2x no mesmo dia) mora numa
   colecao PROPRIA, notifEnviadas/{uid} -- NUNCA em saves/{uid} direto,
   porque empurrarNuvem() faz um setDoc() SEM merge (sobrescreve o
   documento inteiro) toda vez que o client sincroniza. Qualquer campo
   que a gente escrevesse ali seria apagado no proximo save do jogador.

   DEPLOY: ver README.md nesta mesma pasta -- precisa do plano Blaze
   habilitado no projeto Firebase antes (Cloud Functions nao roda no
   Spark/gratis).
   ============================================================================= */

const { onSchedule } = require('firebase-functions/v2/scheduler');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// App e' majoritariamente BR (dungeonlog.weberlabs.com.br) -- fuso fixo
// em vez de por usuario (o app hoje nem guarda o fuso de cada jogador).
// Se um dia isso importar de verdade, precisa comecar guardando o fuso
// no cadastro/onboarding antes de conseguir agendar por pessoa.
const FUSO = 'America/Sao_Paulo';

// Data de hoje em FUSO, formato YYYY-MM-DD -- mesmo formato que
// isoAtual()/isoDe() usam no client (play/index.html). Cloud Functions
// rodam em UTC por padrao, new Date().toISOString() viraria o dia na
// hora errada.
function hojeSP(){
  const partes = new Intl.DateTimeFormat('en-CA', {
    timeZone: FUSO, year: 'numeric', month: '2-digit', day: '2-digit',
  }).formatToParts(new Date());
  const mapa = {};
  partes.forEach(p => { mapa[p.type] = p.value; });
  return mapa.year + '-' + mapa.month + '-' + mapa.day;
}

function diaAnterior(iso){
  const d = new Date(iso + 'T12:00:00Z'); // meio-dia UTC -- evita virar o dia errado por causa de DST/fuso ao subtrair
  d.setUTCDate(d.getUTCDate() - 1);
  return d.toISOString().slice(0, 10);
}

// Mesma regra de estStreakAtual() (play/index.html, bloco "Estatisticas:
// dados reais") -- reimplementada aqui porque Cloud Functions e o client
// nao compartilham codigo nenhum. Mudou lá, muda aqui tambem.
function calcularStreak(hist, hojeIso){
  const porData = new Map(hist.map(h => [h.data, h.resultado]));
  let cursor = hojeIso;
  if (!porData.has(cursor)) cursor = diaAnterior(cursor);
  let streak = 0;
  while (porData.get(cursor) === 'vitoria'){
    streak++;
    cursor = diaAnterior(cursor);
  }
  return streak;
}

function lerExtra(extras, chave){
  if (!extras || typeof extras[chave] !== 'string') return null;
  try { return JSON.parse(extras[chave]); } catch(e){ return null; }
}

// Manda a mensagem pra todos os tokens de uma conta (varios aparelhos) e
// remove da lista qualquer token que o FCM reportou como invalido/
// desregistrado (app desinstalado, permissao revogada no SO, etc) --
// sem isso, fcmTokens/{uid}.tokens so cresceria com lixo pra sempre.
// So `data` no payload (nunca `notification`) de proposito -- garante que
// SEMPRE cai no onBackgroundMessage() do Service Worker
// (play/firebase-messaging-sw.js), que monta a notificacao manualmente
// com o texto certo, em vez de depender de como cada SO/navegador trata
// o campo `notification` de forma diferente.
async function enviarEremoverInvalidos(uid, tokens, dados){
  const resposta = await messaging.sendEachForMulticast({
    tokens,
    data: dados,
    webpush: { fcmOptions: { link: 'https://dungeonlog.weberlabs.com.br/play/' } },
  });

  const invalidos = [];
  resposta.responses.forEach((r, i) => {
    if (!r.success){
      const codigo = r.error && r.error.code;
      if (codigo === 'messaging/registration-token-not-registered' || codigo === 'messaging/invalid-registration-token'){
        invalidos.push(tokens[i]);
      }
    }
  });
  if (invalidos.length){
    const restantes = tokens.filter(t => !invalidos.includes(t));
    await db.collection('fcmTokens').doc(uid).set({ tokens: restantes }, { merge: true });
  }
}

// LIMITACAO CONHECIDA: le fcmTokens inteiro e faz 1 leitura de saves +
// 1 de notifEnviadas por conta, sequencial. Para um app deste tamanho
// (dezenas/centenas de contas com push ativo) isso roda em segundos e
// fica bem dentro da cota gratis do Blaze. Se um dia a base crescer
// muito, a saida e paginar fcmTokens e paralelizar com Promise.all em
// lotes -- nao vale a complexidade agora.

// =============================================================================
// 1) TESTE GRATIS ACABANDO -- 1x por dia, 10h (America/Sao_Paulo). Le
//    extras['questlog.trial.v1'] (ver bloco "TESTE GRATIS", play/index.html)
//    e compara os dias restantes com a preferencia escolhida no paywall
//    (etapa 3, #pwEtapa3 -- 3 dias antes / 1 dia antes / no ultimo dia).
// =============================================================================
exports.notificarTesteGratisAcabando = onSchedule({ schedule: '0 10 * * *', timeZone: FUSO }, async () => {
  const hoje = hojeSP();
  const tokensSnap = await db.collection('fcmTokens').get();

  for (const tokenDoc of tokensSnap.docs){
    const uid = tokenDoc.id;
    const tokens = tokenDoc.data().tokens || [];
    if (!tokens.length) continue;

    const saveSnap = await db.collection('saves').doc(uid).get();
    if (!saveSnap.exists) continue;

    const trial = lerExtra(saveSnap.data().extras, 'questlog.trial.v1');
    if (!trial || typeof trial.fim !== 'number') continue;
    if (Date.now() >= trial.fim) continue; // ja expirou, nada a avisar (voltou pro plano gratis sozinho)

    const diasRestantes = Math.max(0, Math.ceil((trial.fim - Date.now()) / 86400000));
    if (diasRestantes > trial.avisoDias) continue; // ainda nao chegou no limiar escolhido pelo usuario

    const statusRef = db.collection('notifEnviadas').doc(uid);
    const statusSnap = await statusRef.get();
    if (statusSnap.exists && statusSnap.data().trialDia === hoje) continue; // ja avisou hoje

    const corpo = diasRestantes <= 0
      ? 'Seu teste grátis acaba hoje! Assine pra não perder o Plano Pro.'
      : ('Seu teste grátis acaba em ' + diasRestantes + (diasRestantes === 1 ? ' dia! ' : ' dias! ') + 'Assine pra não perder o Plano Pro.');

    await enviarEremoverInvalidos(uid, tokens, {
      titulo: 'Teste grátis acabando',
      corpo,
      tipo: 'trial',
    });
    await statusRef.set({ trialDia: hoje }, { merge: true });
  }
});

// =============================================================================
// 2) FIM DE DIA -- streak em risco + monstro do dia ainda vivo, combinados
//    numa unica notificacao (pedido do usuario pediu os dois gatilhos,
//    mas sao a MESMA causa raiz -- tarefas de hoje pendentes -- juntar
//    evita mandar 2 pushes na mesma noite pelo mesmo motivo). 1x por
//    dia, 20h (America/Sao_Paulo) -- sobra tempo real de completar
//    tarefas antes da virada do dia (meia-noite local, mesmo corte que
//    isoAtual() usa no client).
// =============================================================================
exports.notificarFimDeDia = onSchedule({ schedule: '0 20 * * *', timeZone: FUSO }, async () => {
  const hoje = hojeSP();
  const tokensSnap = await db.collection('fcmTokens').get();

  for (const tokenDoc of tokensSnap.docs){
    const uid = tokenDoc.id;
    const tokens = tokenDoc.data().tokens || [];
    if (!tokens.length) continue;

    const saveSnap = await db.collection('saves').doc(uid).get();
    if (!saveSnap.exists) continue;
    const extras = saveSnap.data().extras;

    // hp.dia precisa ser HOJE -- sincronizar() (play/index.html, modulo
    // VIDA DO MONSTRO) so atualiza esse registro no BOOT do app. Se a
    // conta nao abriu o app hoje, o registro e' de um dia anterior e nao
    // reflete o estado real agora -- nao da pra confiar nele, melhor nao
    // mandar nada do que mandar errado.
    const hp = lerExtra(extras, 'questlog.hpMonstro.v1');
    if (!hp || hp.dia !== hoje) continue;
    const viva = Math.max(0, (hp.total || 0) - (hp.dano || 0));
    if (viva <= 0) continue; // monstro do dia ja foi derrotado, nada a avisar

    const statusRef = db.collection('notifEnviadas').doc(uid);
    const statusSnap = await statusRef.get();
    if (statusSnap.exists && statusSnap.data().fimDiaDia === hoje) continue;

    const hist = lerExtra(extras, 'questlog.hist.v1') || [];
    const streak = calcularStreak(hist, hoje);

    const corpo = streak > 0
      ? ('Sua sequência de ' + streak + (streak === 1 ? ' dia' : ' dias') + ' corre risco! O monstro de hoje ainda tem ' + viva + ' de vida.')
      : ('Você ainda tem tarefas pendentes hoje -- o monstro tem ' + viva + ' de vida restante.');

    await enviarEremoverInvalidos(uid, tokens, {
      titulo: streak > 0 ? 'Sua sequência corre risco!' : 'Tarefas pendentes hoje',
      corpo,
      tipo: 'fimDeDia',
    });
    await statusRef.set({ fimDiaDia: hoje }, { merge: true });
  }
});
