# =====================================================================
#  BAIXAR DADOS DO DELTA SHARING (Databricks Open Share)  ->  para CSV
# =====================================================================
#  O que este script faz:
#    1. Conecta no Delta Share usando o arquivo 'config.share'
#    2. Descobre AUTOMATICAMENTE todas as tabelas compartilhadas
#    3. Baixa TODAS elas e salva em CSV na pasta 'dados/'
#
#  Depois de baixar, voce pode trabalhar OFFLINE com 'explorar_local.R'.
#
#  Pre-requisito: rodar 'install_pacotes.R' uma vez antes.
# =====================================================================


# ---------------------------------------------------------------------
# PASSO 0 - Preparacao (nao precisa mexer)
# ---------------------------------------------------------------------

# Tenta posicionar o R na pasta deste script automaticamente (no RStudio).
# Se nao der certo, use no menu:  Session > Set Working Directory >
# To Source File Location.
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  try(setwd(dirname(rstudioapi::getActiveDocumentContext()$path)), silent = TRUE)
}

library(delta.sharing)
suppressWarnings(suppressMessages(library(dplyr)))


# ---------------------------------------------------------------------
# PASSO 1 - Configuracao
# ---------------------------------------------------------------------

# Caminho do arquivo de credenciais (deve estar na mesma pasta deste script)
CONFIG_SHARE <- "config.share"

# Pasta onde os CSVs serao salvos
PASTA_SAIDA <- "dados"

# Limite de linhas por tabela (para testar sem baixar tudo).
# Use NULL para baixar as tabelas inteiras.  Ex.: LIMITE_LINHAS <- 1000
LIMITE_LINHAS <- NULL


# ---------------------------------------------------------------------
# PASSO 2 - Conectar e DESCOBRIR todas as tabelas
# ---------------------------------------------------------------------

if (!file.exists(CONFIG_SHARE)) {
  stop("Nao encontrei o arquivo '", CONFIG_SHARE, "' na pasta:\n  ", getwd(),
       "\nColoque o config.share aqui e rode de novo.")
}

client <- sharing_client(CONFIG_SHARE)

# Lista todos os shares e, para cada um, todas as tabelas (de todos os schemas).
# Resultado: um data.frame com as colunas 'share', 'schema', 'name'.
shares <- client$list_shares()
cat("Shares encontrados:", paste(shares$name, collapse = ", "), "\n")

todas_tabelas <- dplyr::bind_rows(
  lapply(shares$name, function(s) {
    tryCatch(
      client$list_tables_in_share(share = s),
      error = function(e) {
        cat("[ERRO] Nao consegui listar tabelas do share '", s, "': ",
            conditionMessage(e), "\n", sep = "")
        NULL
      }
    )
  })
)

if (is.null(todas_tabelas) || nrow(todas_tabelas) == 0) {
  stop("Nenhuma tabela encontrada nos shares disponiveis.")
}

cat("\n===== TABELAS ENCONTRADAS (", nrow(todas_tabelas), ") =====\n", sep = "")
print(todas_tabelas)


# ---------------------------------------------------------------------
# PASSO 3 - BAIXAR todas as tabelas e salvar em CSV
# ---------------------------------------------------------------------

if (!dir.exists(PASTA_SAIDA)) {
  dir.create(PASTA_SAIDA, recursive = TRUE)
}

baixar_uma_tabela <- function(share, schema, name) {
  nome <- paste(share, schema, name, sep = ".")
  cat("\n---> Baixando:", nome, "\n")

  ds_tbl <- client$table(share = share, schema = schema, table = name)

  if (!is.null(LIMITE_LINHAS)) {
    ds_tbl$set_limit(LIMITE_LINHAS)
  }

  # Carrega a tabela como tibble (data.frame)
  df <- ds_tbl$load_as_tibble()

  # Nome do arquivo de saida: share__schema__tabela.csv
  arquivo <- file.path(
    PASTA_SAIDA,
    paste0(share, "__", schema, "__", name, ".csv")
  )

  # Salva em CSV com codificacao UTF-8 (mantem acentos)
  readr::write_csv(df, arquivo)

  cat("     OK:", nrow(df), "linhas,", ncol(df), "colunas ->", arquivo, "\n")
  invisible(arquivo)
}

# Baixa TODAS as tabelas, uma por uma.
# Se uma falhar, avisa e continua para a proxima.
n_ok <- 0
n_erro <- 0
for (i in seq_len(nrow(todas_tabelas))) {
  linha <- todas_tabelas[i, ]
  tryCatch({
    baixar_uma_tabela(linha$share, linha$schema, linha$name)
    n_ok <<- n_ok + 1
  }, error = function(e) {
    cat("     [ERRO] Falhou:", linha$share, "/", linha$schema, "/", linha$name,
        "\n            ", conditionMessage(e), "\n")
    n_erro <<- n_erro + 1
  })
}

cat("\n=====================================================\n")
cat(" Concluido. ", n_ok, " tabela(s) baixada(s), ", n_erro, " com erro.\n", sep = "")
cat(" Os CSVs estao na pasta '", PASTA_SAIDA, "/'.\n", sep = "")
cat(" Para trabalhar offline, use 'explorar_local.R'.\n")
cat("=====================================================\n")
