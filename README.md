# FuelBridge PT-BR

Processo ETL em **Pentaho Data Integration** que compara o preço dos combustíveis entre **Portugal (distrito de Braga)** e o **Brasil**, convertendo tudo para euros com a taxa de câmbio do Banco Central Europeu.

Trabalho Prático 1 da unidade curricular **Integração de Sistemas de Informação** (LESI, UPCA, 2026/2027).
Autor: Octavio Rodrigues Schwab (n.º 51239).

## Fontes de dados

| Fonte | Formato | Conteúdo |
|---|---|---|
| DGEG (API de preços dos postos) | JSON | Preços dos postos do distrito de Braga |
| ANP (dados abertos) | CSV | Preços recolhidos em postos de todo o Brasil |
| BCE (taxas de referência) | XML | Taxa de câmbio EUR/BRL dos últimos 90 dias |
| Mapeamento de combustíveis | YAML | Correspondência entre os nomes da DGEG e da ANP |

## Estrutura

```
config/      mapeamento.yaml e exemplo do kettle.properties
dashboard/   dashboard do Grafana (importar o JSON)
data/
  input/     dados brutos (DGEG, ANP, BCE)
  staging/   dados limpos de cada fonte
  output/    fato_precos.csv, comparacao.csv, comparacao.json
  logs/      linhas rejeitadas
etl/         transformações (.ktr) e job principal (.kjb)
sql/         schema.sql (tabelas e vistas do PostgreSQL)
```

## Fluxo

`j_fuelbridge.kjb` corre por ordem:

1. `t_dgeg.ktr`: lê o JSON da DGEG, limpa e normaliza os preços de Portugal.
2. `t_anp.ktr`: lê os CSV da ANP, filtra os combustíveis e limpa os preços do Brasil.
3. `t_bce.ktr`: lê o XML do BCE e calcula a taxa EUR/BRL média por semana ISO.
4. `t_comparacao.ktr`: junta tudo, converte para euros, valida, calcula a diferença PT x BR e carrega o PostgreSQL.
5. Envia por email o `comparacao.csv` em anexo. Se alguma transformação falhar, envia um email de erro e aborta.

## Como executar

1. Instalar o Pentaho Data Integration 10.2 e o PostgreSQL.
2. Copiar o projeto para uma pasta sem acentos nem espaços (por exemplo `C:\projetos\fuelbridge`).
3. Copiar as linhas de `config/kettle.properties.exemplo` para o `kettle.properties` do utilizador e preencher os valores.
4. Criar a base de dados `fuelbridge` e correr `sql/schema.sql`.
5. Abrir `etl/j_fuelbridge.kjb` no Spoon e clicar em **Run**.
6. (Opcional) No Grafana, criar a ligação PostgreSQL e importar `dashboard/fuelbridge_dashboard.json`.

## Resultado (outubro de 2026)

| Combustível | Portugal (€/L) | Brasil (€/L) | Diferença |
|---|---|---|---|
| Gasóleo | 2,199 | 1,220 | +80,2% |
| Gasolina 95 | 2,109 | 1,111 | +89,8% |
