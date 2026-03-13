require 'fog/aws'

if ENV['AWS_ACCESS_KEY_ID'] do
  CarrierWave.configure do |config|
    fog_credentials = {
      provider: 'AWS',
      region: 'us-east-2',
      aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
    }
    Fog::Storage.new(fog_credentials).sync_clock

    config.fog_credentials = fog_credentials
    config.fog_directory = 'infospace-books-app'
    config.fog_public = false
  end
end
