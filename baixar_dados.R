# =====================================================================
#  BAIXAR DADOS DO DELTA SHARING  ->  roda o downloader Python de dentro do R
# =====================================================================
#  Este script R apenas ENCONTRA o Python e executa o 'baixar_dados.py'.
#  O download de verdade e feito pelo Python (conector oficial
#  'delta-sharing'), porque as tabelas usam Deletion Vectors, que o
#  conector R nao le.
#
#  Como usar no RStudio: abra este arquivo e clique em "Source".
#  A saida do Python aparece aqui no console do RStudio.
#
#  Pre-requisitos (rode 'install_pacotes.R' uma vez):
#    - Python instalado
#    - pip install -r requirements.txt
# =====================================================================

# Posiciona o R na pasta deste script (no RStudio)
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  try(setwd(dirname(rstudioapi::getActiveDocumentContext()$path)), silent = TRUE)
}

SCRIPT_PY <- "baixar_dados.py"

# ---------------------------------------------------------------------
# Encontra um Python funcional no sistema (tenta 'python', 'py -3', 'python3')
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
      error = function(e) NULL,
      warning = function(w) NULL
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
  stop(
    "Python nao encontrado no PATH.\n",
    "Instale o Python (https://www.python.org/downloads/) marcando a opcao\n",
    "'Add Python to PATH', e depois rode 'install_pacotes.R'."
  )
}

cat("Python encontrado:", py$versao,
    "  (comando:", py$cmd, paste(py$args, collapse = " "), ")\n\n")

# ---------------------------------------------------------------------
# Executa o downloader Python (a saida vai direto para o console do R).
# O '-u' deixa a saida sem buffer, para acompanhar o progresso em tempo real.
# ---------------------------------------------------------------------
status <- system2(
  py$cmd,
  c(py$args, "-u", shQuote(SCRIPT_PY)),
  stdout = "", stderr = ""
)

if (!identical(as.integer(status), 0L)) {
  cat("\n[ATENCAO] O downloader terminou com codigo", status,
      "- verifique as mensagens acima.\n")
} else {
  cat("\nPronto. Use 'explorar_local.R' para abrir os CSVs no R.\n")
}
