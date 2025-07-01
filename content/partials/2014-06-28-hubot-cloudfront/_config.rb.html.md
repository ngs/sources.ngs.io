# config.rb
activate :cloudfront do |cf|
  cf.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
  cf.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  cf.distribution_id   = ENV['CLOUDFRONT_DISTRIBUTION_ID']
  cf.filter = %r{editor\-inner\.js$}i
  cf.after_build = false
end
