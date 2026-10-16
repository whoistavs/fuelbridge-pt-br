# FuelBridge PT-BR — estado do projeto

Última atualização: 16 de outubro de 2026, 13:25
Entrega: 22 de outubro de 2026 (TP1 de Integração de Sistemas de Informação)

## Feito

| Fase | Transformação | Entrada | Saída | Linhas |
|---|---|---|---|---|
| E + T | `etl/t_dgeg.ktr` | `data/input/dgeg/*.json` (API DGEG) | `data/staging/dgeg_limpo.csv` | 510 |
| E + T | `etl/t_anp.ktr` | `data/input/anp/ultimas-4-semanas-*.csv` (ANP) | `data/staging/anp_limpo.csv` | 67.490 → 30.081 |
| E + T | `etl/t_bce.ktr` | `data/input/bce/eurofxref-hist-90d.xml` (BCE) | `data/staging/bce_semanal.csv` e `bce_diario.json` | 64 → 14 semanas |
| T | `etl/t_comparacao.ktr` | as três saídas acima + `config/mapeamento.yaml` | `data/output/fato_precos.csv`, `comparacao.csv`, `comparacao.json` | 30.591 → 2 |

Resultado: em euros, o gasóleo em Braga custa +80,2% (2,199 €/L contra 1,220 €/L) e a gasolina 95 custa +89,8% (2,109 €/L contra 1,111 €/L) do que a média do Brasil.

Fase L (15 out.):
- Base de dados PostgreSQL 18 (`fuelbridge`, `sql/schema.sql`): `fato_precos` (30.591) e `comparacao` carregadas pela t_comparacao (Table output, ligação partilhada `fuelbridge_pg`).
- Job `etl/j_fuelbridge.kjb`: Start → t_dgeg → t_anp → t_bce → t_comparacao → anexar_comparacao → email_resumo → Success. Testado com sucesso.
- Email de resumo (Gmail SMTP 465 SSL) com o `comparacao.csv` em anexo. Testado.
- Email de erro: cada transformação liga ao `email_erro` (seta vermelha) → Abort job. Testado (t_bce trocado por um ficheiro inexistente e reposto).
- Variáveis `MAIL_USER`, `MAIL_PASS`, `MAIL_TO` no `kettle.properties` (a palavra-passe não vai para o Git).
- Dashboard Grafana (localhost:3000, ligação `fuelbridge_pg`): `dashboard/fuelbridge_dashboard.json` (importar em Dashboards → New → Import). 6 painéis: diferença %, registos carregados, última execução, barras PT x BR, preço semanal, histórico. Fuso horário do dashboard: UTC.
- Prints na P1: JOB_Canvas, JOB_Metrics, EMAIL_Recebido, JOB_Erro_Canvas, EMAIL_Erro, DASHBOARD, GIT_Push.
- Senha do PostgreSQL na conexão `fuelbridge_pg` trocada por `${PG_PASS}` (variável no `kettle.properties`).
- Repositório GitHub público: https://github.com/whoistavs/fuelbridge-pt-br (README, .gitignore, config/kettle.properties.exemplo). Pasta `doc/` fica fora do Git.

Relatório: secções 1 a 4 escritas (DGEG, ANP, BCE e comparação), com as Figuras 1 a 9.

## Configuração necessária

- Variável `FUELBRIDGE_HOME=C:/projetos/fuelbridge` no `kettle.properties` (pasta `C:\Users\User\.kettle`).
- O projeto tem de estar num caminho sem acentos nem espaços.
- Pentaho Data Integration 10.2.

## Lições aprendidas

- Escrever os valores à mão no Pentaho: copiar de tabelas traz TABs e espaços invisíveis.
- Usar sempre File → Save e confirmar com OK (não Cancel) ao fechar um step.
- O YAML Input precisa de um documento YAML por linha, separados por `---`, sem comentários antes do primeiro `---`.
- Text file output: clicar em Minimal width para não encher os campos com espaços.
- Ao ligar um step a dois destinos, escolher Copy (e não Distribute).
- Não salvar consultas do pgAdmin por cima do `sql/schema.sql` (aconteceu em 15 out.; arquivo reposto).
- Para atualizar o GitHub: `git add .`, `git commit -m "mensagem"`, `git push`.
- Grafana: para atualizar um dashboard importado, apagar o antigo na lista de Dashboards e importar de novo.
- O Spoon não corre um Job com alterações por gravar: gravar sempre antes de Run.
- Fechar o Word antes de o Claude gravar o relatório (o AutoSave do OneDrive repõe a versão antiga).

## Próximos passos (fase L)

1. ~~Base de dados~~ ✔
2. ~~Email de resumo e de erro~~ ✔
3. ~~Job principal~~ ✔ (opcional: ficheiro de log em `data/logs`)
4. ~~Dashboard Grafana~~ ✔
5. ~~Repositório Git~~ ✔ https://github.com/whoistavs/fuelbridge-pt-br (falta colocar o link na planilha compartilhada)
6. Relatório: secção da carga/BD, 5 (Jobs), 6 (vídeo com QR Code), 7 (conclusão) e 8 (referências).
