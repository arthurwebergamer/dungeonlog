# Notificações push do DungeonLog — deploy (Cloudflare Worker, sem custo)

Isto substitui a ideia inicial de usar Firebase Cloud Functions — aquela
exigia o plano Blaze (cartão cadastrado). Este caminho roda inteiro no
plano **gratuito** do Cloudflare Workers (mesma conta que já hospeda o
app no Cloudflare Pages) e não pede cartão em lugar nenhum.

Ainda são passos manuais — eu (Claude) não tenho login nem credenciais
pra fazer isso por você.

## 1. Gerar a Service Account do Firebase (grátis, não precisa de Blaze)

Console do Firebase → engrenagem → **Configurações do projeto** → aba
**Contas de serviço** → **Gerar nova chave privada**. Baixa um arquivo
`.json` — guarda ele, é a credencial que o Worker vai usar pra ler o
Firestore e mandar push. **Nunca** comite esse arquivo no repositório.

## 2. Gerar a VAPID key (se ainda não fez)

Console do Firebase → engrenagem → **Configurações do projeto** → aba
**Cloud Messaging** → seção **Configuração da Web** → **Gerar par de
chaves**. Cola a chave em `play/index.html`, procure por
`COLE_AQUI_SUA_VAPID_KEY` (constante `VAPID_KEY`).

## 3. Instalar o Wrangler (CLI do Cloudflare Workers)

```
npm install -g wrangler
wrangler login
```

## 4. Configurar o secret com a Service Account

Da pasta `cf-worker/`:

```
cd cf-worker
wrangler secret put FIREBASE_SERVICE_ACCOUNT
```

Quando pedir o valor, cola o **conteúdo inteiro** do arquivo `.json`
baixado no passo 1 (é só um texto JSON numa linha só ou não, tanto faz —
o Worker faz `JSON.parse` nele).

## 5. Deploy

Ainda na pasta `cf-worker/`:

```
wrangler deploy
```

Isso publica o Worker e registra os 2 Cron Triggers (10h e 20h, horário
de Brasília — já convertidos pra UTC em `wrangler.toml`, Brasil não tem
mais horário de verão desde 2019, então não precisa reajustar 2x por
ano).

## 6. Ativar as regras do Firestore (se ainda não fez)

Esse passo é do Firebase, não do Cloudflare, mas também é grátis (não
precisa de Blaze — regras de segurança do Firestore são grátis em
qualquer plano):

```
npm install -g firebase-tools   # se ainda não tiver
firebase login
firebase deploy --only firestore:rules
```

## 7. Testar sem esperar o horário

O Worker responde a um GET simples (não é um endpoint público de nada
sensível, só dispara as checagens na hora):

```
curl https://dungeonlog-push.<seu-subdominio>.workers.dev
```

A URL exata aparece no terminal depois do `wrangler deploy`. Depois de
confirmar que funciona, se quiser travar esse atalho de teste, é só
apagar o método `fetch` em `src/index.js` e rodar `wrangler deploy` de
novo — o Worker continua rodando pelo Cron normalmente.

## Limites (sim, existem — números reais)

Grátis não é ilimitado. O que importa de verdade aqui:

- **100.000 requisições/dia** no plano gratuito do Workers — irrelevante
  pra gente, só disparamos 2x por dia (mais alguma chamada manual de
  teste).
- **10ms de CPU por execução** — é tempo de *processamento*, não de
  espera de rede (os `fetch()` pra Firestore/FCM não contam nisso).
  Folgado pro que o Worker faz (conversões de JSON, laços simples).
- **50 subrequests (chamadas `fetch()`) por execução — este é o que
  importa.** Cada notificação mandada gasta 1 subrequest por token (a
  API do FCM não manda pra vários de uma vez). Fora isso, o Worker faz
  só um punhado fixo de chamadas por execução (2 pra pegar token de
  acesso, 1 pra listar quem tem push ativo, 2 lotes pra ler os dados de
  todo mundo de uma vez, 1 pra salvar tudo no final) — leitura/escrita
  no Firestore são **agrupadas em lote** de propósito (`batchGet`/
  `commit`), então não crescem por conta.

  Na prática: cada execução aguenta em torno de **~40 contas recebendo
  notificação naquele dia** antes de estourar o limite (a conta exata
  varia um pouco conforme quantos precisam ter token limpo). Isso é bem
  mais do que a base atual do app, mas **não é infinito** — se um dia
  crescer além disso, a saída é dividir em vários Workers/horários (ex:
  processar metade das contas às 20h e a outra metade às 20h15) ou
  migrar pra uma fila (Cloudflare Queues, ainda no plano gratuito). Não
  vale a complexidade agora, mas é bom saber que o teto existe.

- **Firestore (qualquer plano, inclusive Spark)**: 50.000 leituras e
  20.000 escritas por dia, de graça. Como as leituras/escritas já são
  agrupadas em lote, a base atual do app fica muito longe disso.
- **FCM (envio de push)**: sem limite prático nenhum, é grátis pra
  qualquer volume.

## O que cada checagem faz

- **10h BRT**: teste grátis acabando — lê `questlog.trial.v1` de cada
  conta com push ativado e manda o aviso quando os dias restantes
  baterem com a preferência escolhida no paywall (3 dias antes / 1 dia
  antes / no último dia).
- **20h BRT**: se o monstro do dia ainda não foi derrotado, manda um
  único aviso combinando "streak em risco" (se houver sequência ativa)
  com quanto de vida o monstro ainda tem.

Nenhuma delas manda notificação pra quem nunca clicou em "Ativar" em
Configurações → Notificações (é isso que cria o documento em
`fcmTokens/{uid}`).

## Por que não Cloud Functions

Cloud Functions do Firebase só roda no plano Blaze (mesmo uma função
simples, sem nenhum custo real na prática) porque a execução em si roda
sobre Cloud Run por baixo dos panos, e isso exige cartão cadastrado no
projeto. Ler e escrever no Firestore, e mandar mensagens pelo FCM, são
**grátis em qualquer plano** — o Worker aqui só reimplementa, via
chamadas HTTP diretas (REST API do Firestore + API v1 do FCM,
autenticado como a Service Account do passo 1), exatamente o que as
Cloud Functions fariam — sem precisar do Blaze pra nada.

## Google Play Billing: `POST /billing/verify`

O app (TWA) compra via Digital Goods API e manda `{sku, purchaseToken}` com
`Authorization: Bearer <ID token do Firebase>`. O Worker:

1. valida o ID token (JWKS do Firebase) e pega o `uid`;
2. consulta a Google Play Developer API (`subscriptionsv2` / `purchases/products`);
3. confirma (acknowledge) a compra pendente (senao a Google estorna em 3 dias);
4. amarra o token a um unico uid (`playPurchases/{sha256(token)}`);
5. grava `entitlements/{uid}` (`assinaturaAte`, `assinaturaProduto`, `assinaturaEstado`
   ou `proVitalicio`/`proVitalicioPlay`).

Para ativar:

- Google Cloud: ativar a **Google Play Android Developer API** no projeto.
- Play Console > Usuarios e permissoes: convidar o `client_email` da service account
  com permissao de **ver dados financeiros / gerenciar pedidos e assinaturas** do app.
- (Opcional) secret `PLAY_SERVICE_ACCOUNT` com outra service account so pra Play;
  sem ele usa `FIREBASE_SERVICE_ACCOUNT`.
- `npx wrangler deploy`
- Em `play/index.html`, preencher `BILLING_VERIFY_URL` com `https://<worker>/billing/verify`
  (vazio = o pop-up de compra nunca abre, de proposito).
- Ainda nao ha RTDN: renovacoes/cancelamentos sao pegos quando o app abre
  (`billingSincronizar`, a cada 6h).


## Reembolsos (compras anuladas)

O cron `0 8 * * *` (5h em Brasilia) roda `revogarComprasAnuladas`: lista
`purchases.voidedpurchases` (type=1, ultimos 7 dias), acha o dono por
`playPurchases/{sha256(token)}` e desliga so aquela compra em
`entitlements/{uid}` (`proVitalicio=false` ou `assinaturaAte=0`). Marca
`playPurchases/{hash}.anuladaEm` (idempotente). A service account precisa
da permissao de dados financeiros no Play Console (a mesma do billing).
Depois de mexer no cron: `npx wrangler deploy` (o novo cron entra no deploy).

### Disparo manual (so o dono)

`POST /admin/revogar-anuladas` com `Authorization: Bearer <ADMIN_TOKEN>` roda
o robo na hora e devolve `{ok, vistas, revogadas}`. Precisa do secret
`ADMIN_TOKEN` (`wrangler secret put ADMIN_TOKEN`); sem ele o caminho da 404.
