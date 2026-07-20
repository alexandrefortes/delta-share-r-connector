# Conector Delta Sharing (Databricks Open Share) para R / RStudio

Conecta no **Delta Sharing** do Databricks, baixa as tabelas compartilhadas
e salva em **CSV** para trabalhar **offline** no RStudio. Tudo em R — não
precisa de Python.

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `install_pacotes.R` | Instala tudo que é necessário. **Roda uma vez só.** |
| `baixar_dados.R` | Conecta e baixa **todas** as tabelas compartilhadas em CSV. |
| `explorar_local.R` | Abre os CSVs já baixados para explorar **sem internet**. |
| `config.share.exemplo` | Modelo do arquivo de credenciais. |
| `config.share` | **Você cria este** com as suas credenciais (veja abaixo). |
| `dados/` | Pasta criada automaticamente com os CSVs baixados. |

## Passo a passo (Windows + RStudio)

### 1. Instalar o R e o RStudio (se ainda não tiver)
- R: https://cran.r-project.org/bin/windows/base/
- RStudio: https://posit.co/download/rstudio-desktop/

### 2. Colocar o arquivo de credenciais
Coloque o seu arquivo `config.share` **nesta pasta**, ao lado dos scripts.
O conteúdo tem este formato (é o que o Databricks fornece):

```json
{"shareCredentialsVersion":1,"bearerToken":"...","endpoint":"https://...","expirationTime":"9999-12-31T23:59:59.999Z","icebergEndpoint":"https://..."}
```

> O cliente usa o campo **`endpoint`** (protocolo Delta Sharing) e o
> **`bearerToken`**. O campo `icebergEndpoint` **não é usado** por este
> conector — pode deixar como está.

### 3. Instalar os pacotes (uma vez só)
Abra `install_pacotes.R` no RStudio e clique em **Source**.
Pode demorar alguns minutos (o pacote `arrow` é grande).

### 4. Baixar todas as tabelas
Abra `baixar_dados.R` e clique em **Source**. Ele conecta, descobre
**sozinho** todas as tabelas compartilhadas e baixa cada uma para a pasta
`dados/` (um CSV por tabela, no formato `share__schema__tabela.csv`).

O console mostra a lista de tabelas encontradas e o progresso de cada
download. Se alguma falhar, ele avisa e continua nas demais.

> Dica: para testar antes de baixar tudo, defina `LIMITE_LINHAS <- 1000`
> no topo do script — assim ele baixa só as primeiras 1000 linhas de cada
> tabela.

### 6. Trabalhar offline
Abra `explorar_local.R` e clique em **Source**. Ele lê os CSVs da pasta
`dados/` — não precisa de internet nem do `config.share`.

## Problemas comuns

- **"Nao encontrei o arquivo 'config.share'"** → o arquivo não está na
  pasta certa, ou o RStudio não está apontando para ela. Use no menu:
  *Session > Set Working Directory > To Source File Location*.
- **Erro pedindo para compilar / instalar Rtools** → instale o Rtools:
  https://cran.r-project.org/bin/windows/Rtools/ e rode
  `install_pacotes.R` de novo.
- **Erro de autenticação / token** → o `bearerToken` pode ter expirado.
  Peça um `config.share` novo a quem compartilhou os dados.

## Referências

- Pacote R `delta.sharing`: https://github.com/zacdav-db/delta-sharing-r
- Projeto Delta Sharing (delta-io): https://github.com/delta-io/delta-sharing
