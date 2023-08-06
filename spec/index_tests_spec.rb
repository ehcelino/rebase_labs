require_relative 'spec_helper'
require_relative '../server'
require_relative '../core/import'
require 'sinatra'
require 'capybara'
require 'selenium-webdriver'

@options = Selenium::WebDriver::Chrome::Options.new
@options.add_argument('--headless')
@options.add_argument('--no-sandbox')
@options.add_argument('--cors-exempt-headers')

Capybara.register_driver :remote_chrome do |app|
  Capybara::Selenium::Driver.new(app,
    :browser              => :remote,
    :url                  => 'http://selenium-hub:4444',
    :options => @options,
  )
end

Capybara.default_driver = :remote_chrome
Capybara.app_host = 'http://rebase-labs:3000'
Capybara.always_include_port = true


RSpec.describe 'Acessa a página principal', type: :feature do
  def app
    Sinatra::Application
  end

  it 'e vê as informações da página' do
    # Arrange

    # Act
    visit('/index?env=test')

    # Assert
    expect(page).to have_content 'Aplicativo de exames'
    expect(page).to have_link 'testes sem formatação'
    expect(page).to have_link 'testes em formato json'
    expect(page).to have_link 'detalhes de um exame'
    expect(page).to have_link 'fila do sidekiq'
    expect(page).to have_css('label', text: 'Importar arquivo csv')
    expect(page).to have_css('input#search')
  end

  it 'e vê os exames listados' do
    # Arrange

    # Act
    visit('/index?env=test')

    # Assert
    expect(page).to have_content 'IQCZ17'
    expect(page).to have_content '05/08/2021'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    expect(page).to have_content '11/03/2001'
    expect(page).to have_content 'Maria Luiza Pires'
    expect(page).to have_css('button#IQCZ17')
    expect(page).to have_content '0W9I67'
    expect(page).to have_content '09/07/2021'
    expect(page).to have_content '048.108.026-04'
    expect(page).to have_content 'Juliana dos Reis Filho'
    expect(page).to have_content '03/07/1995'
    expect(page).to have_content 'Maria Helena Ramalho'
  end

  it 'e vê detalhes de um exame' do
    # Arrange
    
    # Act
    visit('/index?env=test')
    find(:css, '#IQCZ17').click

    # Assert
    expect(page).to have_content 'IQCZ17'
    expect(page).to have_content '05/08/2021'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    expect(page).to have_content '11/03/2001'
    expect(page).to have_content 'Maria Luiza Pires'
    expect(page).to have_content 'B000BJ20J4'
    expect(page).to have_content 'PI'
    expect(page).to have_content 'hemácias'
    expect(page).to have_content '45-52'
    expect(page).to have_content '97'
    expect(page).to have_content 'ácido úrico'
    expect(page).to have_content '15-61'
    expect(page).to have_content '2'
    expect(page).to have_button 'Voltar'
  end

  it 'e busca por um token de exame' do
    # Arrange

    # Act
    visit('/index?env=test')
    fill_in 'search', with: 'IQCZ17'
    click_on 'Pesquisar'

    # Assert
    expect(page).to have_content 'IQCZ17'
    expect(page).to have_content '05/08/2021'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    expect(page).to have_content '11/03/2001'
    expect(page).to have_content 'Maria Luiza Pires'
    expect(page).to have_content 'B000BJ20J4'
    expect(page).to have_content 'PI'
    expect(page).to have_content 'hemácias'
    expect(page).to have_content '45-52'
    expect(page).to have_content '97'
    expect(page).to have_content 'ácido úrico'
    expect(page).to have_content '15-61'
    expect(page).to have_content '2'
    expect(page).to have_button 'Voltar'
  end

  it 'e abre a listagem de exames sem formatação' do
    # Arrange

    # Act
    visit('/index?env=test')
    click_on 'testes sem formatação'

    # Assert
    expect(page).to have_content 'IQCZ17'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    expect(page).to have_content 'Maria Luiza Pires'
  end

  it 'e abre a listagem de exames em formato json' do
    # Arrange

    # Act
    visit('/index?env=test')
    click_on 'testes em formato json'

    # Assert
    expect(page).to have_content 'IQCZ17'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    expect(page).to have_content 'Maria Luiza Pires'
  end
end