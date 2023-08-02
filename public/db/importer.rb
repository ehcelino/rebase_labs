require 'sidekiq'

class Importer
  include Sidekiq::Worker
  include Sidekiq::Job
  sidekiq_options retry: false, dead: false
  def perform(file)
    require_relative 'import'
    TransferData.make_transfer(file)
  end
end