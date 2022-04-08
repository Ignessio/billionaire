require 'rails_helper'

RSpec.describe Game, type: :model do
  # пользователь для создания игр
  let(:user) { create(:user) }

  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # генерим 60 вопросов с 4х запасом по полю level,
      # чтобы проверить работу RANDOM при создании игры
      generate_questions(60)

      game = nil
      # создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(# проверка: Game.count изменился на 1 (создали в базе 1 игру)
        change(GameQuestion, :count).by(15).and(# GameQuestion.count +15
          change(Question, :count).by(0) # Game.count не должен измениться
        )
      )
      # проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      # проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  # Тесты на основную игровую логику
  context 'game mechanics' do
    # Правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # Проверяем начальный статус игры
      level = game_w_questions.current_level
      # Текущий вопрос
      q = game_w_questions.current_game_question
      # Проверяем, что статус in_progress
      expect(game_w_questions.status).to eq(:in_progress)

      # Выполняем метод answer_current_question! и сразу передаём верный ответ
      game_w_questions.answer_current_question!(q.correct_answer_key)

      # Проверяем, что уровень изменился
      expect(game_w_questions.current_level).to eq(level + 1)

      # Проверяем, что изменился текущий вопрос
      expect(game_w_questions.current_game_question).not_to eq(q)

      # Проверяем, что игра продолжается/не закончена
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end
end
