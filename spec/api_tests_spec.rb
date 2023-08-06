require_relative 'spec_helper'
require_relative '../server'
require_relative '../core/import'
require 'sinatra'

RSpec.describe 'Testes de API' do
  def app
    Sinatra::Application
  end

  after :each do
    conn = PG.connect(host:'postgres', user:'postgres', password:'postgres', dbname:'test')
    conn.exec('DROP TABLE exams; DROP TABLE tokens; DROP TABLE patients; DROP TABLE doctors;')
  end

  it 'entrega os testes sem formatação a partir de /tests' do
    # Arrange
    data = CSV.read('./spec/support/data.csv').flatten.join("\n")
    TransferData.make_transfer(data)

    # Act
    get '/tests'

    # Assert
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('IQCZ17')
    expect(last_response.body).to include('Emilly Batista Neto')
    expect(last_response.body).to include('Maria Luiza Pires')
    expect(last_response.body).to include('0W9I67')
    expect(last_response.body).to include('Juliana dos Reis Filho')
    expect(last_response.body).to include('Maria Helena Ramalho')
  end

  it 'entrega os testes como JSON em /tests/fmt=json' do
    # Arrange
    data = CSV.read('./spec/support/data.csv').flatten.join("\n")
    TransferData.make_transfer(data)

    # Act
    get '/tests/fmt=json'
    body = JSON.parse(last_response.body)

    # Assert
    expect(last_response.status).to eq 200
    expect(last_response.content_type).to include 'application/json'
    expect(body.class).to eq Array
    expect(body.first.values).to include('IQCZ17')
    expect(body.first.values).to include('Emilly Batista Neto')
    expect(body.first['doctor'].values).to include('Maria Luiza Pires')
    expect(body.first.keys).to include('result_token')

  end

  it "entrega os dados de apenas um exame em formato JSON em /tests/:token" do
    # Arrange
    data = CSV.read('./spec/support/data.csv').flatten.join("\n")
    TransferData.make_transfer(data)
    
    # Act
    get '/tests/IQCZ17'
    body = JSON.parse(last_response.body)

    # Assert
    expect(last_response.status).to eq 200
    expect(last_response.content_type).to include 'application/json'
    expect(body.class).to eq Array
    expect(body.first.values).to include('IQCZ17')
    expect(body.first.values).to include('Emilly Batista Neto')
    expect(body.first['doctor'].values).to include('Maria Luiza Pires')
    expect(body.first.keys).to include('result_token')
  end 
end