source 'https://rubygems.org'

ruby '2.5.8'

gem 'sassc-rails'
gem 'rails', '~> 4.2.6'
# Удобная админка для управления любыми сущностями
gem 'rails_admin'
gem 'devise', '~> 4.4.0'
gem 'devise-i18n'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'twitter-bootstrap-rails'
gem 'font-awesome-rails'
gem 'russian'
gem 'pg', '~> 0.15'

group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'

  # Гем, который использует rspec, чтобы смотреть наш сайт
  gem 'capybara'

  # Гем, который позволяет смотреть, что видит capybara
  gem 'launchy'
end

group :production do
  # гем, улучшающий вывод логов на Heroku
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  gem 'rails_12factor'
end
