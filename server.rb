require 'sinatra'
require 'rack/handler/puma'
require 'rack'
require_relative './core/retrieve'
require_relative './core/importer'

before do
  headers 'Access-Control-Allow-Origin'  => 'http://localhost:3000',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

get '/tests' do
  Retrieve.generate_json
end

get '/tests/fmt=json' do
  content_type :json
  PatientData.generate_json
end

get '/tests/:token' do
  content_type :json
  PatientData.search(params['token'])
end

get '/index' do
  content_type :html
  File.open('html/index.html')
end

get '/index?env=test' do
  content_type :html
  File.open('html/index.html')
end


post '/import' do
  file = request.body.read
  Importer.perform_async(file)
end

if ENV['APP_ENV'] != 'test'
  Rack::Handler::Puma.run(
    Sinatra::Application,
    Port: 3000,
    Host: '0.0.0.0'
  )
end