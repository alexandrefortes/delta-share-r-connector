# =====================================================================
#  INSTALACAO DAS DEPENDENCIAS  ->  RODAR UMA VEZ SO
# =====================================================================
#  Conector Delta Sharing (Databricks Open Share).
#
#  O download e feito em PYTHON (conector oficial 'delta-sharing'),
#  porque as tabelas usam Deletion Vectors, que o conector R nao le.
#  O R serve para: disparar o Python e explorar os CSVs baixados.
#
#  Este script:
#    1. Instala os pacotes R necessarios
#    2. Instala as dependencias Python (pip install -r requirements.txt)
#
#  Como usar: abra no RStudio e clique em "Source".
#  Pre-requisito: ter o Python instalado (com "Add Python to PATH").
# =====================================================================

# Posiciona o R na pasta deste script (no RStudio)
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  try(setwd(dirname(rstudioapi::getActiveDocumentContext()$path)), silent = TRUE)
}

options(repos = c(CRAN = "https://cloud.r-project.org"))

# ---------------------------------------------------------------------
# 1) Pacotes R (usados para explorar os CSVs em 'explorar_local.R')
# ---------------------------------------------------------------------
pacotes_r <- c(
  "readr",     # ler/salvar CSV (UTF-8)
  "dplyr",     # manipulacao de dados
  "rstudioapi" # achar a pasta do projeto (ja vem no RStudio)
)

for (pkg in pacotes_r) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Instalando pacote R: ", pkg)
    install.packages(pkg)
  } else {
    message("Pacote R ja instalado: ", pkg)
  }
}

# ---------------------------------------------------------------------
# 2) Dependencias Python (pip install -r requirements.txt)
# ---------------------------------------------------------------------
encontrar_python <- function() {
  candidatos <- list(
    list(cmd = "python",  args = character(0)),
    list(cmd = "py",      args = "-3"),
    list(cmd = "python3", args = character(0))
  )
  for (c in candidatos) {
    versao <- tryCatch(
      system2(c$cmd, c(c$args, "--version"), stdout = TRUE, stderr = TRUE),
      error = function(e) NULL, warning = function(w) NULL
    )
    if (!is.null(versao) && length(versao) > 0 && any(grepl("Python", versao))) {
      c$versao <- versao[1]
      return(c)
    }
  }
  NULL
}

py <- encontrar_python()

if (is.null(py)) {
  message("\n[ATENCAO] Python nao encontrado no PATH.")
  message("Instale o Python (https://www.python.org/downloads/) marcando")
  message("'Add Python to PATH' e rode este script de novo.")
  message("Ou instale manualmente no terminal:  pip install -r requirements.txt")
} else {
  message("\nPython encontrado: ", py$versao)
  message("Instalando dependencias Python (pip install -r requirements.txt)...")
  status <- system2(
    py$cmd,
    c(py$args, "-m", "pip", "install", "-r", "requirements.txt"),
    stdout = "", stderr = ""
  )
  if (!identical(as.integer(status), 0L)) {
    message("\n[ATENCAO] O pip terminou com codigo ", status,
            ". Veja as mensagens acima.")
  }
}

message("\n==============================================")
message(" Setup concluido.")
message(" Proximo passo: coloque o 'config.share' na pasta")
message(" e rode 'baixar_dados.R'.")
message("==============================================")
