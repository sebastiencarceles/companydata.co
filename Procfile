web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -e production -q default -q mailers
release: bundle exec rails db:migrate
