## Description

  This application being an  interactive variation of the popular game Who Wants to Be a Billionaire.
  There are 15 level each with one question and 4 answer suggestions.
  The player has to choose the most correct answer from his point of view. Player can use one of 3 help types before answering.
  There are 3 fireproof levels with guaranteed prize.

## Language and framework

  * Ruby 2.5.8
  * Rails 4.2.6

## How to play

  You can start game online:
  ```
  https://be-lucky.herokuapp.com/
  ```
  In order to play offline the following steps to be completed.

  * Download folder from repository or use clonning
  ```
  git clone git@github.com:Ignessio/billionaire
  ```
  * Install required labraries
  ```
  bundle install
  ```
  * Create database and apply migrations
  ```
  bundle exec rails db:create db:migrate
  ```
  * In order to fill in questions database you need to set admin access for registered user.
  * You can find full questions set in /public/questions_full/
  * For test purpooses only you can use testing questions set, execute:
  ```
  bundle exec rails db:seed
  ```
  * Start rails server using
  ```
  bundle exec rails start
  ```
  * Open new window in preffered browser and enter page address
  ```
  http://localhost:3000/
  ```

## Administration

  * Start rails console
  ```
  rails c
  ```
  * Assign to selected user administrative access
  ```
  user.update(is_admin: true)
  ```
  * Return to normal mode
  ```
  exit
  ```
  Admin mode is now avalable and you can upload full set of questions to database.
