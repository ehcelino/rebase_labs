require_relative 'spec_helper'
require_relative '../server'
require_relative '../core/import'
require 'sinatra'

RSpec.describe 'Testes de API' do
  def app
    Sinatra::Application
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
    expect(last_response.body).to include('0W9I67')
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
    expect(body.first.values).to include('IQCZ17')
    expect(body.class).to eq Array
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
    expect(body.first.values).to include('IQCZ17')
    expect(body.class).to eq Array
    expect(body.first.keys).to include('result_token')
  end 
end