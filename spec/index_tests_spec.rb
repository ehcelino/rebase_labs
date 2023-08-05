require_relative 'spec_helper'
require_relative '../server'
require_relative '../core/import'
require 'sinatra'
require 'capybara'
require 'selenium-webdriver'

# Capybara.default_driver = :selenium
# Selenium::WebDriver::Firefox::Binary.path = '/usr/bin/firefox'

# options = Selenium::WebDriver::Firefox::Options.new
# options.binary = "/usr/bin/firefox" 
# driver = Selenium::WebDriver.for :firefox, options: options

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
# Capybara.server = :puma
# Capybara.app_host = 'http://0.0.0.0:3000'
Capybara.app_host = 'http://rebase-labs:3000'
Capybara.always_include_port = true


RSpec.describe 'Acessa a página principal', type: :feature do
  def app
    Sinatra::Application
  end

  it 'e vê as informações da página' do
    # Arrange
    file = File.open('./spec/support/data.csv')
    TransferData.make_transfer(file)

    # Act
    visit('/index')

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
    file = File.open('./spec/support/data.csv')
    TransferData.make_transfer(file)

    # Act
    # sleep 1
    visit('/index?env=test')
    # sleep 1
    # page.attach_file('csv', './spec/support/data.csv', make_visible: true)
    # sleep 15
    # visit('/tests')

    # Assert
    page.save_screenshot
    expect(page).to have_content 'IQCZ17'
    expect(page).to have_content '05/08/2021'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    expect(page).to have_content '11/03/2001'
    expect(page).to have_content 'Maria Luiza Pires'
    expect(page).to have_css('button#IQCZ17')
  end

  it 'e abre a listagem de exames sem formatação' do
    # Arrange
    file = File.open('./spec/support/data.csv')
    TransferData.make_transfer(file)

    # Act
    visit('/index')
    click_on 'testes sem formatação'

    # Assert
    # page.save_screenshot
    expect(page).to have_content 'IQCZ17'
    # expect(page).to have_content '05/08/2021'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    # expect(page).to have_content '11/03/2001'
    expect(page).to have_content 'Maria Luiza Pires'
    # expect(page).to have_css('button#IQCZ17')
  end

  it 'e abre a listagem de exames em formato json' do
    # Arrange
    file = File.open('./spec/support/data.csv')
    TransferData.make_transfer(file)

    # Act
    visit('/index')
    click_on 'testes em formato json'

    # Assert
    # page.save_screenshot
    expect(page).to have_content 'IQCZ17'
    # expect(page).to have_content '05/08/2021'
    expect(page).to have_content '048.973.170-88'
    expect(page).to have_content 'Emilly Batista Neto'
    # expect(page).to have_content '11/03/2001'
    expect(page).to have_content 'Maria Luiza Pires'
    # expect(page).to have_css('button#IQCZ17')
  end
end