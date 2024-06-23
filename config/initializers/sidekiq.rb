Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' } # Redis server URL and database number
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' } 
end