require_relative 'spec_helper'
require_relative '../core/import'
require_relative '../core/retrieve'
require 'csv'
require 'json'

describe 'Método que' do

  after :each do
    conn = PG.connect(host:'postgres', user:'postgres', password:'postgres', dbname:'test')
    conn.exec('DROP TABLE exams; DROP TABLE tokens; DROP TABLE patients; DROP TABLE doctors;')
  end

  it 'retorna todos os registros do banco de dados como string' do
    # Arrange
    file = File.open('./spec/support/data.csv')
    
    # Act
    TransferData.make_transfer(file)
    records = Retrieve.generate_json

    # Assert
    # expect(records.class).to eq Array
    expect(records).to include '048.973.170-88'
    expect(records).to include 'Emilly Batista Neto'
    expect(records).to include 'Matheus Barroso'
  end

  it 'retorna todos os registros do banco de dados organizados' do
    # Arrange
    file = File.open('./spec/support/data.csv')
    
    # Act
    TransferData.make_transfer(file)
    records = PatientData.generate_json

    # Assert
    expect(records).to include '048.973.170-88'
    expect(records).to include 'Emilly Batista Neto'
    expect(records).to include 'Matheus Barroso'
  end

  it 'retorna os dados de um exame' do
    # Arrange
    file = File.open('./spec/support/data.csv')
    
    # Act
    TransferData.make_transfer(file)
    record = PatientData.search('IQCZ17')

    # Assert
    expect(record).to include '048.973.170-88'
    expect(record).to include 'Emilly Batista Neto'
    expect(record).not_to include 'Matheus Barroso'
  end
end