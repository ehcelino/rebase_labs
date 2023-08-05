# Rebase Labs

Uma app web para listagem de exames médicos.

---

## Introdução

A app foi desenvolvida no princípio SPA (Single Page Application), onde as alterações na visualização são feitas pelo Javascript diretamente no DOM. Na primeira execução serão baixadas as imagens necessárias e também as gems, que então ficarão disponíveis dentro de um volume. É necessário popular o banco de dados através do arquivo import_from_csv.rb ou pela opção na página inicial.

## Banco de dados

![imagem bd](/internal/rebase_labs.png)

## Pré requisitos

- ruby

- docker

- docker-compose

## Executando a app

No diretório raiz, execute:

`$ bin/run`

## API Endpoints

- /tests

Entrega todos os exames sem formatação a partir do banco de dados

- /tests/fmt=json

Entrega todos os exames em formato json

- /tests/:token

Entrega todos os dados de um exame relacionado ao token em formato json
