# Rebase Labs

Uma app web para listagem de exames médicos.

---

Eduardo Celino, TreinaDev turma 10

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

em seguida acesse:

http://localhost:3000/index

O arquivo de dados para importação se encontra em:

`/public/support/data.csv`

## API Endpoints

- /tests

Entrega todos os exames sem formatação a partir do banco de dados

- /tests/fmt=json

Entrega todos os exames em formato json

- /tests/:token

Entrega todos os dados de um exame relacionado ao token em formato json

## URL's do app

- http://localhost:3000/index ou http://localhost:3000/

Página principal do app

- http://localhost:3000/index?env=test

Caminho do ambiente de testes do capybara

## Testes

## Observação: para rodar os testes do capybara o banco de dados principal do app deve estar populado.

Os testes são realizados pela suite RSpec, com o apoio do Rack e Capybara (usando o driver Selenium). Enquanto os testes normais rodam usando um banco de dados específico, os testes do Capybara dependem do banco de dados principal da aplicação. Estou trabalhando em uma solução para este problema, mas por enquanto para que os testes do Capybara sejam executados é necessário que o banco de dados principal esteja populado.

Para executar os testes, em uma janela do terminal digite:

`$ docker exec -it rebase-labs bash`

e em seguida

`$ rspec`