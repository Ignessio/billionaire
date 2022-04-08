require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: переменная будет создаваться заново для каждого блока it, где её вызываем
  # Распределяем варианты ответов по-своему
  let(:game_question) { create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  context 'game status' do
    # Тест на правильную генерацию хеша с вариантами
    it 'correct .variants' do
      # Ожидаем, что варианты ответов будут соответствовать тем,
      # которые мы написали выше
      expect(game_question.variants).to eq(
        'a' => game_question.question.answer2,
        'b' => game_question.question.answer1,
        'c' => game_question.question.answer4,
        'd' => game_question.question.answer3
      )
    end

    # Проверяем метод answer_correct?
    describe '#correct_answer?' do
      it 'check answer_correct?' do
        expect(game_question.answer_correct?('b')).to be(true)
      end
    end

    # Проверяем метод correct_answer_key
    describe '#correct_answer_key' do
      it 'returns the key of the correct answer' do
        expect(game_question.correct_answer_key).to eq('b')
      end
    end

    # Проверяем метод делегирования текста и уровня вопросу
    it 'correct .level & .text delegates' do
      expect(game_question.text).to eq(game_question.question.text)
      expect(game_question.level).to eq(game_question.question.level)
    end
  end
end
