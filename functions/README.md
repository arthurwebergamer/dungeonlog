# Notificações push do DungeonLog — deploy

Este diretório é o backend das 3 notificações push pedidas: teste grátis
acabando, streak em risco e monstro do dia ainda vivo. O app (Cloudflare
Pages) não muda de lugar — só isto aqui roda no Firebase.

Nada disto acontece sozinho: precisa ser feito manualmente, uma vez, pelo
dono do projeto Firebase (`questlog-d4c11`). Eu (Claude) não tenho login
nem credenciais para rodar esses passos daqui.

## 1. Upgrade pro plano Blaze

Cloud Functions **não roda no plano gratuito (Spark)** — precisa do
**Blaze** (pago por uso, mas a cota gratis mensal cobre tranquilamente o
uso deste app: 2 funções rodando 1x/dia cada). Precisa de cartão
cadastrado, mas não deve gerar cobrança no seu volume atual.

Console do Firebase → engrenagem (canto superior esquerdo) → **Utilização
e faturamento** → **Fazer upgrade do plano** → escolher Blaze.

## 2. Gerar a VAPID key (Web Push certificate)

Console do Firebase → engrenagem → **Configurações do projeto** → aba
**Cloud Messaging** → seção **Configuração da Web** → **Gerar par de
chaves** (se ainda não existir nenhuma).

Copia a chave gerada (começa com letras/números longos) e cola em
`play/index.html`, bloco `NOTIFICACOES PUSH` — procure pelo texto
`COLE_AQUI_SUA_VAPID_KEY` (constante `VAPID_KEY`). Só esse um lugar —
o Service Worker (`firebase-messaging-sw.js`) não precisa da chave,
ela só é usada na hora de pedir o token, no `index.html`.

## 3. Instalar o Firebase CLI (se ainda não tiver)

```
npm install -g firebase-tools
firebase login
```

## 4. Instalar as dependências das functions

```
cd functions
npm install
```

## 5. Deploy

Da raiz do repositório (não de dentro de `functions/`):

```
firebase deploy --only functions,firestore:rules
```

Isso publica as 2 Cloud Functions (`notificarTesteGratisAcabando`,
`notificarFimDeDia`) e as regras de segurança do Firestore
(`firestore.rules`, na raiz do repo — cobre as coleções `saves`,
`fcmTokens` e `contadorGlobal`; era "modo de teste" liberado geral antes
disso).

## 6. Conferir que rodou

```
firebase functions:log
```

Cada função só dispara automaticamente no horário agendado (10h e 20h,
horário de Brasília). Pra testar sem esperar, dá pra rodar manualmente
pelo Console do Firebase → Functions → selecionar a função → "Testar
função", ou via `gcloud scheduler jobs run <nome-do-job> --location=...`
depois do primeiro deploy (o Firebase cria o job do Cloud Scheduler
automaticamente).

## O que cada função faz

- **`notificarTesteGratisAcabando`** (10h BRT, todo dia): lê o teste
  grátis de cada conta com notificação ativada e manda o aviso quando
  os dias restantes baterem com a preferência escolhida no paywall
  (3 dias antes / 1 dia antes / no último dia).
- **`notificarFimDeDia`** (20h BRT, todo dia): se o monstro do dia ainda
  não foi derrotado, manda um único aviso combinando "streak em risco"
  (se houver sequência ativa) e quanto de vida o monstro ainda tem.

Nenhuma delas manda notificação pra quem nunca ativou (`fcmTokens/{uid}`
só existe pra quem clicou em "Ativar" em Configurações → Notificações).
