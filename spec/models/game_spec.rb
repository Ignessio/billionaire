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
      expect(game_w_questions.finished?).to be(false)
    end
  end

  # Проверяем метод take_money!
  describe '#take_money!' do
    it 'finish the game, change user balance' do
      game_w_questions.take_money!

      expect(game_w_questions.status).to eq(:money)
      expect(game_w_questions.finished?).to be(true)
      expect(user.balance).to eq(game_w_questions.prize)
    end
  end

  # Тесты на статус завершенной игры
  describe '#status of completed game' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be(true)

      it 'returns game status :won' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it 'returns game status :fail' do
        game_w_questions.is_failed
        expect(game_w_questions.status).to eq(:failed)
      end

      it 'returns game status :timeout' do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end
    end
  end

  describe '#previous_level' do
    it 'returns previous question level' do
      game_w_questions.current_level = 1
      expect(game_w_questions.previous_level).to eq(0)
    end
  end

  describe '#current_game_question' do
    it 'returns current game question' do
      expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions.first)
    end
  end

  describe '#answer_current_question!' do
    context 'when answer is correct' do
      let(:question) { game_w_questions.current_game_question }

      it 'keeps game in progress' do
        expect(game_w_questions.answer_current_question!('d')).to be(true)
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.finished?).to be(false)
      end

      context 'and answer last question' do
        before do
          game_w_questions.current_level = Question::QUESTION_LEVELS.max
          game_w_questions.answer_current_question!(question.correct_answer_key)
        end

        it 'completes the game as won' do
          expect(game_w_questions.status).to eq(:won)
          expect(game_w_questions.finished?).to be(true)
        end

        it 'assignes the last level fireproff prize' do
          expect(game_w_questions.prize).to eq(Game::PRIZES.last)
        end
      end

      context 'and time is over' do
        before do
          game_w_questions.created_at = 1.hour.ago
        end

        it 'completes the game as failed' do
          expect(game_w_questions.answer_current_question!('d')).to be(false)
          expect(game_w_questions.status).to eq(:timeout)
          expect(game_w_questions.finished?).to be(true)
        end
      end
    end

    context 'when answer is incorrect' do
      it 'completes the game as failed' do
        expect(game_w_questions.answer_current_question!('a')).to be(false)
        expect(game_w_questions.status).to eq(:fail)
        expect(game_w_questions.finished?).to be(true)
      end
    end
  end
end
