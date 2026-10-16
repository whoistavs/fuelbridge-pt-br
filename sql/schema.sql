-- FuelBridge PT-BR - estrutura da base de dados (PostgreSQL)
-- Correr uma vez, na base de dados "fuelbridge", pelo Query Tool do pgAdmin.

-- Registos individuais de preco (um por posto e combustivel), ja em euros.
-- Carregada pela t_comparacao (Table output, com truncate em cada execucao).
DROP TABLE IF EXISTS fato_precos CASCADE;
CREATE TABLE fato_precos (
    id              SERIAL PRIMARY KEY,
    pais            CHAR(2)        NOT NULL,   -- PT ou BR
    combustivel_id  VARCHAR(30)    NOT NULL,   -- codigo comum do mapeamento.yaml
    municipio       VARCHAR(120),
    data            DATE           NOT NULL,   -- data de atualizacao (PT) ou de recolha (BR)
    ano             INTEGER        NOT NULL,   -- ano ISO 8601
    semana          INTEGER        NOT NULL,   -- semana ISO 8601
    moeda           CHAR(3)        NOT NULL,   -- EUR ou BRL
    preco_local     NUMERIC(10,3)  NOT NULL,   -- preco na moeda do pais
    taxa_media      NUMERIC(10,4)  NOT NULL,   -- taxa EUR/BRL da semana (1 para PT)
    preco_eur       NUMERIC(10,3)  NOT NULL,   -- preco convertido para euros
    carregado_em    TIMESTAMP      NOT NULL DEFAULT now()
);

CREATE INDEX idx_fato_pais_comb ON fato_precos (pais, combustivel_id);
CREATE INDEX idx_fato_semana    ON fato_precos (ano, semana);

-- Resultado da comparacao PT x BR, uma linha por combustivel e por execucao.
-- Guarda o historico: cada execucao do ETL acrescenta linhas novas.
DROP TABLE IF EXISTS comparacao CASCADE;
CREATE TABLE comparacao (
    id              SERIAL PRIMARY KEY,
    combustivel_id  VARCHAR(30)    NOT NULL,
    preco_pt        NUMERIC(10,4)  NOT NULL,   -- media em Portugal (EUR/L)
    preco_br        NUMERIC(10,4)  NOT NULL,   -- media no Brasil (EUR/L)
    n_pt            INTEGER        NOT NULL,
    n_br            INTEGER        NOT NULL,
    dif_eur         NUMERIC(10,4)  NOT NULL,   -- preco_pt - preco_br
    dif_pct         NUMERIC(8,2)   NOT NULL,   -- diferenca em %
    razao           NUMERIC(8,3)   NOT NULL,   -- preco_pt / preco_br
    executado_em    TIMESTAMP      NOT NULL DEFAULT now()
);

-- Vista para o dashboard: preco medio por semana, pais e combustivel.
CREATE OR REPLACE VIEW v_preco_semanal AS
SELECT ano,
       semana,
       pais,
       combustivel_id,
       ROUND(AVG(preco_eur), 3) AS preco_medio_eur,
       COUNT(*)                 AS n_registos
FROM fato_precos
GROUP BY ano, semana, pais, combustivel_id
ORDER BY ano, semana, pais, combustivel_id;

-- Vista para o dashboard: ultima comparacao de cada combustivel.
CREATE OR REPLACE VIEW v_comparacao_atual AS
SELECT DISTINCT ON (combustivel_id) *
FROM comparacao
ORDER BY combustivel_id, executado_em DESC;
