# Fase 3: aba Perfil, Conquistas, Bestiário, Grimório e Configurações

## Fiel ao app original (conferido no navegador, 390x844, tema grafite)
- **Perfil**: cabeçalho "Perfil" + "Nível N" + engrenagem, anel SVG 210 (XP por fora, vida por dentro, herói de 110 px), nome, legenda Vida/XP, cartões Conquistas (com bolinha de novas) e Bestiário (faixa de 6 casas). Medidas do CSS computado; posições batem.
- **Conquistas**: é a **V2** (18 marcos, lista plana com data e etiqueta NOVO), `lib/dominio/conquistas.dart`. Chaves por herói: `questlog.conquistasDesbloqueadasV2.v1`, `questlog.conquistasVistasV2.v1`. Bolinha no ícone do Perfil e no "Ver todas".
- **Bestiário / ficha do monstro / oculto**, **Grimório** (catálogo, ficha, ficha oculta; abre pelo botão "Abrir" do item) e a entrega do Grimório no marco de nível IV a VII (`4 + semente % 4`, som `grimorio`, bloco "Você encontrou Grimório" no popup de nível).
- **Configurações**: principal, Heróis (lista, trocar, lápis), Editar herói (renomear, sprite, excluir), Novo herói, Aparência, Preferências (feedback tátil, som, CRT, golpes variados, notificações), Idioma, Gerenciar conta, links legais (`url_launcher`).
- Chaves do original usadas: `questlog.hist.v1`, `questlog.itensVistos.v1`, `questlog.sfx.v1` ({ativo, volume, feedback}), `questlog.crt.v1`, `questlog.golpesVariados.v1`, `questlog.idioma.v1`, `questlog.tema.v1`, `questlog.personagens.v1`, `questlog.personagemAtivo.v1`.
- O histórico agora é GRAVADO na virada do dia (mesmo formato `{data, resultado, monstroId, tarefas}`, mais a "recuperação de ontem" do original). A Fase 4 só precisa ler.

## Regras e testes
- Paridade com o JS (`tools/gerar_casos_js.mjs` extrai as funções reais): 250 casos de conquistas/contexto/sequência, definições (nomes, cores, textos PT/EN) e nível do Grimório. Mutação feita (sequência de vitórias errada) e o teste falhou em >100 casos.
- `test/perfil_test.dart`: histórico na virada, bestiário de hoje, itens vistos, Grimório, conquistas e NOVO, preferências, heróis (criar/trocar preservando o save/excluir) e as telas.
- O gerador agora normaliza CRLF do index.html.

## Temas de cor
As cores de `tema.dart` viraram getters sobre uma **paleta global** (`Paleta.atual`); trocar o tema reconstrói a árvore inteira sem perder o estado. Seis temas (Branco, Escuro, Laranja, Dourado grátis; Esmeralda, Terracota PRO, bloqueados com selo). Botões primários e abas ativas usam `corAccent`. Efeito CRT: linhas, franjas RGB, vinheta e cintilação (`crt.dart`).

## Difere do original, e por quê
- **Atributos e linha de estatísticas** não existem: o CSS do original os esconde (`.anelAtr`, `.anelStatsLinha`, `.anelOculto`). O herói no anel é a imagem simples (como no original), não o equipado.
- **Resgate de conquistas**: o "V2 com resgate" não existe no app atual; o resgate com XP é código morto da V1 (nenhum botão o chama). Não foi portado.
- **Lista de heróis** mostra o nome real do save (o original preferia o nome da criação, que ficava velho após renomear: bug corrigido).
- Cortina da troca de herói cobre também as telas de Configurações (no original ela fica por baixo delas).
- Idioma: troca textos do Perfil, Configurações, conquistas, catálogo e nomes de monstros/itens; o resto da UI (Tarefas, Inventário, Loja) segue em PT.
- CRT sem a sombra cromática do texto nem o filtro de saturação (filtros de fundo travavam o celular). Notificações: só a preferência local (`questlog.notificacoes.v1`, chave só do Flutter).
- O "Volume" do som não tem controle no original (só liga/desliga); o valor salvo é preservado.
- Temas: o app ainda tem alguns textos/ícones fixos em branco de fases anteriores, que não seguem o accent.
- Cantos de 4 px da linha NOVO foram omitidos (limitação do Flutter com borda não uniforme).

## Depende de fases futuras
- Conta (login, sair, excluir, ID), nuvem: Fase 6. Plano Pro, paywall, temas Esmeralda/Terracota, mais de 1 herói, restaurar compra, push: Fase 7 (`EstadoJogo.ehPro` é `false`; "+ Novo herói" e temas Pro mostram "Disponível em breve").
- "Rever tutorial": Fase 5. Estatísticas completas e leitura do histórico: Fase 4.

## Não verificado
- No celular (fluidez, vibração real, som, abrir links, CRT em tempo real). O navegador embutido roda a ~1 quadro/s.

## Nota de CI
O build do GitHub pode falhar sozinho ao baixar o NDK do Android (`Error reading Zip content`, falha da infraestrutura, não do código). O workflow agora tenta o build uma segunda vez.
