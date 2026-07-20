# Conector Delta Sharing (Databricks Open Share)

Conecta no **Delta Sharing** do Databricks, baixa as tabelas compartilhadas
em **CSV** e permite explorá-las **offline** no RStudio.

## Por que Python + R?

Suporta tabelas compartilhadas que usam o recurso **Deletion Vectors** do
Delta Lake. O conector **R** (`delta.sharing`) só lê o formato antigo
(parquet puro) e **não** consegue ler essas tabelas — o servidor devolve
`HTTP 400 (DS_UNSUPPORTED_DELTA_TABLE_FEATURES)`.

Por isso o **download** é feito pelo conector **Python oficial**
(`delta-sharing`), que suporta Deletion Vectors. O **R** continua no
comando: um script R (`baixar_dados.R`) dispara o Python e mostra tudo no
console do RStudio, e depois você explora os CSVs em R (`explorar_local.R`).

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `install_pacotes.R` | Instala os pacotes R **e** as dependências Python. **Roda uma vez.** |
| `baixar_dados.R` | Script R que executa o downloader Python e baixa **todas** as tabelas. |
| `baixar_dados.py` | O downloader em si (Python). Chamado pelo `baixar_dados.R`. |
| `requirements.txt` | Dependências Python (`delta-sharing`, `pandas`, `pyarrow`). |
| `explorar_local.R` | Abre os CSVs já baixados para explorar **sem internet**. |
| `config.share.exemplo` | Modelo do arquivo de credenciais. |
| `config.share` | **Você cria este** com as suas credenciais (veja abaixo). |
| `dados/` | Pasta criada automaticamente com os CSVs baixados. |

## Passo a passo (Windows + RStudio)

### 1. Ter o R e o RStudio instalados
- R: https://cran.r-project.org/bin/windows/base/
- RStudio: https://posit.co/download/rstudio-desktop/

### 2. Instalar o Python (Windows)
1. Baixe o instalador em https://www.python.org/downloads/windows/
   (clique em **Download Python 3.x** — a versão mais recente serve).
2. Execute o instalador e, **na primeira tela**, marque a caixa
   **"Add python.exe to PATH"** (no rodapé). Isso é essencial — sem ela,
   o R não encontra o Python.
3. Clique em **Install Now** e aguarde terminar.
4. **Feche e reabra o RStudio** (para ele enxergar o Python recém-instalado).
5. (Opcional) Para conferir, abra o **Prompt de Comando** (tecla Windows,
   digite `cmd`) e rode:
   ```
   python --version
   ```
   Deve aparecer algo como `Python 3.12.x`.

> Se você já tem Python instalado, pode pular esta etapa. Só garanta que
> ele está no PATH (o teste do `python --version` acima confirma).

### 3. Instalar as dependências (uma vez só)
Abra `install_pacotes.R` no RStudio e clique em **Source**. Ele instala os
pacotes R e roda o `pip install -r requirements.txt` automaticamente.

### 4. Colocar o arquivo de credenciais
Coloque o seu `config.share` **nesta pasta**, ao lado dos scripts. Formato:

```json
{"shareCredentialsVersion":1,"bearerToken":"...","endpoint":"https://...","expirationTime":"9999-12-31T23:59:59.999Z","icebergEndpoint":"https://..."}
```

> O conector usa o campo **`endpoint`** e o **`bearerToken`**. O campo
> `icebergEndpoint` **não é usado** — pode deixar como está.

### 5. Baixar todas as tabelas
Abra `baixar_dados.R` e clique em **Source**. Ele encontra o Python,
executa o download e salva um CSV por tabela em `dados/`
(`share__schema__tabela.csv`). O progresso aparece no console do RStudio.

> Dica: para testar antes de baixar tudo, edite `LIMITE_LINHAS = 1000` no
> topo do `baixar_dados.py` — assim ele baixa só as primeiras 1000 linhas
> de cada tabela.

### 6. Trabalhar offline
Abra `explorar_local.R` e clique em **Source**. Ele lê os CSVs da pasta
`dados/` — não precisa de internet nem do `config.share`.

## Rodar sem RStudio (opcional)

O download também funciona direto pelo Python, no terminal:

```bash
pip install -r requirements.txt
python baixar_dados.py
```

## Problemas comuns

- **"Python nao encontrado no PATH"** → instale o Python marcando
  *Add Python to PATH*, ou reinstale com essa opção, e rode de novo.
- **"O pacote 'delta-sharing' nao esta instalado"** → rode
  `install_pacotes.R`, ou no terminal: `pip install -r requirements.txt`.
- **`HTTP 400 ... DS_UNSUPPORTED_DELTA_TABLE_FEATURES`** → isso acontece no
  conector **R**. Use o fluxo em Python descrito aqui (é justamente o que
  ele resolve).
- **Erro de autenticação / token** → o `bearerToken` pode ter expirado.
  Peça um `config.share` novo a quem compartilhou os dados.

## Referências

- Conector Python `delta-sharing` (delta-io): https://github.com/delta-io/delta-sharing
- Deletion Vectors (Delta Lake): https://docs.databricks.com/aws/en/delta/deletion-vectors
