# -*- coding: utf-8 -*-
# =====================================================================
#  BAIXAR DADOS DO DELTA SHARING (Databricks Open Share)  ->  para CSV
# =====================================================================
#  Downloader em Python. Usa o conector oficial 'delta-sharing', que
#  suporta tabelas com Deletion Vectors (formato delta) - coisa que o
#  conector R nao faz.
#
#  Descobre AUTOMATICAMENTE todas as tabelas compartilhadas e salva
#  cada uma em CSV na pasta 'dados/'.
#
#  Pode rodar de dois jeitos:
#    1. Pelo R:      Source em 'baixar_dados.R'  (recomendado p/ RStudio)
#    2. Direto:      python baixar_dados.py
#
#  Pre-requisito:  pip install -r requirements.txt
# =====================================================================

import os
import sys

# ---------------------------------------------------------------------
# Configuracao
# ---------------------------------------------------------------------
CONFIG_SHARE = "config.share"   # arquivo de credenciais (mesma pasta)
PASTA_SAIDA = "dados"           # onde os CSVs serao salvos
LIMITE_LINHAS = None            # None = tudo. Ex.: 1000 para testar rapido.

# ---------------------------------------------------------------------
# Import do conector (com mensagem amigavel se nao estiver instalado)
# ---------------------------------------------------------------------
try:
    import delta_sharing
except ImportError:
    sys.exit(
        "\n[ERRO] O pacote 'delta-sharing' nao esta instalado.\n"
        "Rode no terminal (ou deixe o install_pacotes.R fazer):\n"
        "    pip install -r requirements.txt\n"
    )


def listar_tabelas_unicas(client):
    """Lista todas as tabelas dos shares, removendo duplicatas."""
    tabelas = client.list_all_tables()
    vistas = set()
    unicas = []
    for t in tabelas:
        chave = (t.share, t.schema, t.name)
        if chave not in vistas:
            vistas.add(chave)
            unicas.append(t)
    return unicas


def baixar_uma(t):
    """Baixa uma tabela como pandas DataFrame e salva em CSV."""
    nome = f"{t.share}.{t.schema}.{t.name}"
    print(f"\n---> Baixando: {nome}", flush=True)

    # url no formato:  <perfil>#<share>.<schema>.<tabela>
    url = f"{CONFIG_SHARE}#{t.share}.{t.schema}.{t.name}"

    # use_delta_format nao e passado de proposito: o conector le o
    # metadado e escolhe sozinho delta (deletion vectors) ou parquet.
    if LIMITE_LINHAS:
        df = delta_sharing.load_as_pandas(url, limit=LIMITE_LINHAS)
    else:
        df = delta_sharing.load_as_pandas(url)

    arquivo = os.path.join(
        PASTA_SAIDA, f"{t.share}__{t.schema}__{t.name}.csv"
    )
    df.to_csv(arquivo, index=False, encoding="utf-8")
    print(f"     OK: {len(df)} linhas, {df.shape[1]} colunas -> {arquivo}",
          flush=True)


def main():
    print("Pasta de trabalho:", os.getcwd(), flush=True)

    if not os.path.exists(CONFIG_SHARE):
        sys.exit(
            f"\n[ERRO] Nao encontrei o arquivo '{CONFIG_SHARE}' na pasta:\n"
            f"  {os.getcwd()}\n"
            "Coloque o config.share aqui e rode de novo.\n"
        )

    os.makedirs(PASTA_SAIDA, exist_ok=True)

    client = delta_sharing.SharingClient(CONFIG_SHARE)
    tabelas = listar_tabelas_unicas(client)

    if not tabelas:
        sys.exit("Nenhuma tabela encontrada nos shares disponiveis.")

    print(f"\n===== TABELAS ENCONTRADAS ({len(tabelas)}) =====", flush=True)
    for t in tabelas:
        print(f"  - {t.share}.{t.schema}.{t.name}", flush=True)

    n_ok = 0
    n_erro = 0
    for t in tabelas:
        try:
            baixar_uma(t)
            n_ok += 1
        except Exception as e:
            print(f"     [ERRO] Falhou: {t.share}/{t.schema}/{t.name}\n"
                  f"            {e}", flush=True)
            n_erro += 1

    print("\n=====================================================", flush=True)
    print(f" Concluido. {n_ok} tabela(s) baixada(s), {n_erro} com erro.",
          flush=True)
    print(f" Os CSVs estao na pasta '{PASTA_SAIDA}/'.", flush=True)
    print(" Para trabalhar offline no R, use 'explorar_local.R'.", flush=True)
    print("=====================================================", flush=True)

    # codigo de saida != 0 se nada foi baixado (ajuda o R a avisar)
    if n_ok == 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
