require_relative 'spec_helper'
require_relative '../server'
require_relative '../public/db/import'
require 'sinatra'

RSpec.describe 'Testes de API' do
  def app
    Sinatra::Application
  end

  it 'recebe os testes sem formatação a partir de /tests' do
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

  it 'recebe os testes como JSON em /tests/fmt=json' do
    # Arrange
    data = CSV.read('./spec/support/data.csv').flatten.join("\n")
    TransferData.make_transfer(data)

    # Act
    get '/tests/fmt=json'

    # Assert
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('IQCZ17')
    expect(last_response.body).to include('0W9I67')
  end

  it "recebe os dados de apenas um exame em formato JSON em /tests/:token" do
    # Arrange
    data = CSV.read('./spec/support/data.csv').flatten.join("\n")
    TransferData.make_transfer(data)
    
    # Act
    get '/tests/IQCZ17'

    # Assert
    expect(last_response.status).to eq 200
    expect(last_response.body).to include('IQCZ17')
    expect(last_response.body).not_to include('OX1I67')
    expect(JSON.parse(last_response.body).class).to eq Array
    expect(JSON.parse(last_response.body).first.keys).to include('result_token')
  end 
end