# =====================================================================
#  INSTALACAO DOS PACOTES  ->  RODAR UMA VEZ SO
# =====================================================================
#  Conector Delta Sharing (Databricks Open Share) para R / RStudio.
#
#  Como usar:
#    1. Abra este arquivo no RStudio
#    2. Clique em "Source" (ou selecione tudo e Ctrl+Enter)
#    3. Espere terminar. Pode demorar alguns minutos (o 'arrow' e grande).
#
#  Windows: normalmente NAO precisa de Rtools, pois os pacotes vem
#  como binarios prontos do CRAN. Se em algum momento aparecer um erro
#  pedindo para compilar, instale o Rtools:
#    https://cran.r-project.org/bin/windows/Rtools/
# =====================================================================

# Usar o CRAN oficial (binarios prontos para Windows)
options(repos = c(CRAN = "https://cloud.r-project.org"))

# ---------------------------------------------------------------------
# 1) 'remotes' -> necessario para instalar o pacote a partir do GitHub
# ---------------------------------------------------------------------
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# ---------------------------------------------------------------------
# 2) Dependencias (todas do CRAN, instalam como binario no Windows)
# ---------------------------------------------------------------------
dependencias <- c(
  "arrow",     # leitura dos dados baixados (formato parquet)
  "dplyr",     # manipulacao de dados
  "jsonlite",  # leitura do config.share
  "httr2",     # requisicoes HTTP para o servidor Delta Sharing
  "magrittr",  # operador %>%
  "progress",  # barra de progresso do download
  "purrr",     # utilitarios
  "tibble",    # data.frames "arrumados"
  "readr",     # salvar/ler CSV (UTF-8)
  "rstudioapi" # descobrir a pasta do projeto automaticamente (ja vem no RStudio)
)

for (pkg in dependencias) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Instalando: ", pkg)
    install.packages(pkg)
  } else {
    message("Ja instalado: ", pkg)
  }
}

# ---------------------------------------------------------------------
# 3) Pacote 'delta.sharing' (cliente Delta Sharing para R)
#    Fonte: https://github.com/zacdav-db/delta-sharing-r
# ---------------------------------------------------------------------
message("Instalando o pacote 'delta.sharing' a partir do GitHub...")
remotes::install_github("zacdav-db/delta-sharing-r", upgrade = "never")

# ---------------------------------------------------------------------
# 4) Verificacao final
# ---------------------------------------------------------------------
ok <- requireNamespace("delta.sharing", quietly = TRUE)
if (ok) {
  message("\n==============================================")
  message(" OK! Instalacao concluida com sucesso.")
  message(" Proximo passo: abra e rode 'baixar_dados.R'.")
  message("==============================================")
} else {
  message("\n[ATENCAO] O pacote 'delta.sharing' nao foi encontrado apos a ",
          "instalacao. Reveja as mensagens de erro acima.")
}
