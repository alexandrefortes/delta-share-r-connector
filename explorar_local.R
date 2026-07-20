# =====================================================================
#  EXPLORAR OS DADOS LOCALMENTE (OFFLINE)
# =====================================================================
#  Le os CSVs ja baixados pela pasta 'dados/'. NAO precisa de internet
#  nem do config.share aqui - so trabalha com o que ja foi baixado.
#
#  Rode 'baixar_dados.R' antes, pelo menos uma vez.
# =====================================================================

# Posiciona o R na pasta deste script (no RStudio)
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  try(setwd(dirname(rstudioapi::getActiveDocumentContext()$path)), silent = TRUE)
}

suppressWarnings(suppressMessages(library(dplyr)))

PASTA_DADOS <- "dados"

# Lista os CSVs disponiveis na pasta
arquivos <- list.files(PASTA_DADOS, pattern = "\\.csv$", full.names = TRUE)

if (length(arquivos) == 0) {
  stop("Nenhum CSV encontrado em '", PASTA_DADOS, "/'. ",
       "Rode 'baixar_dados.R' primeiro.")
}

cat("Arquivos disponiveis:\n")
print(basename(arquivos))

# ---------------------------------------------------------------------
# Carregar UM arquivo especifico
# ---------------------------------------------------------------------
# Troque o indice [1] pelo arquivo que voce quer, ou informe o caminho.
arquivo_escolhido <- arquivos[1]
cat("\nCarregando:", basename(arquivo_escolhido), "\n")

dados <- readr::read_csv(arquivo_escolhido, show_col_types = FALSE)

# Uma olhada rapida
cat("\nDimensoes:", nrow(dados), "linhas x", ncol(dados), "colunas\n\n")
print(dplyr::glimpse(dados))

# A partir daqui o 'dados' e um data.frame normal do R.
# Exemplos:
#   head(dados)
#   summary(dados)
#   View(dados)               # abre a planilha no RStudio
#   dados %>% filter(...) %>% group_by(...) %>% summarise(...)
