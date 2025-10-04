rm(list=ls())

library(readxl)
library(dplyr)
library(ggplot2)
library(arrow)

# Carregar arquivo parquet do raw
dados_sim_parquet <- read_parquet('https://github.com/cleodecker/Cancer/raw/refs/heads/main/Base_Dados/dados_sim.parquet')
dados_sim <- as.data.frame(dados_sim_parquet)

# Verificar variáveis
str(dados_sim)
summary(dados_sim)
head(dados_sim)

# Filtrar nas variáveis de interesse - LINHAA, LINHAB, LINHAC, LINHAD, LINHAII E CAUSABAS os valores C00, C01, C02, C03, C04, C05, C06, C07, C08
# Lista de padrões para filtrar
padroes <- c('C00', 'C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08')

# Filtrar linhas onde qualquer variável contém algum dos padrões
dados_filtrados <- dados_sim %>%
  filter(
    grepl(paste(padroes, collapse = "|"), LINHAA) |
      grepl(paste(padroes, collapse = "|"), LINHAB) |
      grepl(paste(padroes, collapse = "|"), LINHAC) |
      grepl(paste(padroes, collapse = "|"), LINHAD) |
      grepl(paste(padroes, collapse = "|"), LINHAII) |
      grepl(paste(padroes, collapse = "|"), CAUSABAS)
  )
         

# Selecionar variáveis de interesse
dados_selecionados <- dados_filtrados %>%
  select(DTOBITO, DTNASC, IDADE, SEXO, RACACOR, ESTCIV, ESC, CODMUNRES, CODMUNOCOR,
         LINHAA, LINHAB, LINHAC, LINHAD, LINHAII, CAUSABAS)

# Cria uma nova variável IDADE, eliminando o número 4 da frente e deixando como inteiro
dados_selecionados$IDADE <- as.integer(sub("^4", "", dados_selecionados$IDADE))

# Transforma o valor de idade correspondente a 5**, como 1**
dados_selecionados$IDADE[dados_selecionados$IDADE >= 500] <- dados_selecionados$IDADE[dados_selecionados$IDADE >= 500] - 400

# Cria uma variável ANO_OBITO extraindo o ano da data de óbito
dados_selecionados <-  dados_selecionados %>%
  mutate(
    ANO_OBITO = format(as.Date(DTOBITO, format = "%Y-%m-%d"), "%Y")
  )

# Gravar selecionados em parquet
write_parquet(dados_selecionados, 'dados_cancer.parquet')
