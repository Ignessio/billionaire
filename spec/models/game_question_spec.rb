require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: переменная будет создаваться заново для каждого блока it, где её вызываем
  # Распределяем варианты ответов по-своему
  let(:game_question) { create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe '#variants' do
    it 'returns answer variants' do
      expect(game_question.variants).to eq(
        'a' => game_question.question.answer2,
        'b' => game_question.question.answer1, # правильный ответ
        'c' => game_question.question.answer4,
        'd' => game_question.question.answer3
      )
    end
  end

  describe '#correct_answer?' do
    it 'returns true for correct answer' do
      expect(game_question.answer_correct?('b')).to be(true)
    end
  end

  describe '#correct_answer_key' do
    it 'returns correct answer key' do
      expect(game_question.correct_answer_key).to eq('b')
    end
  end

  describe '#level' do
    it 'delegates to queston' do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe '#text' do
    it 'delegates to queston' do
      expect(game_question.text).to eq(game_question.question.text)
    end
  end

  describe '.help_hash' do
    context 'when help not used' do
      it 'returns empty' do
        expect(game_question.help_hash).to eq({})
      end
    end

    context 'when any help is used' do
      before do
        game_question.help_hash[:some_key1] = 'blabla1'
        game_question.help_hash['some_key2'] = 'blabla2'
      end

      it 'returns saved' do
        expect(game_question.save).to be(true)
        expect(GameQuestion.find(game_question.id).help_hash).to eq({some_key1: 'blabla1', 'some_key2' => 'blabla2'})
      end
    end
  end

  describe '#add_fifty_fifty' do
    it 'returns empty before use' do
        expect(game_question.help_hash).not_to include(:fifty_fifty)
    end

    context 'when used fifty_fifty' do
      before { game_question.add_fifty_fifty }

      it 'contains fifty_fifty' do
        expect(game_question.help_hash).to include(:fifty_fifty)
      end

      it 'includes correct answer key' do
        expect(game_question.help_hash[:fifty_fifty]).to include('b')
      end
    end
  end

  describe '#add_audience_help' do
    it 'returns empty before use' do
      expect(game_question.help_hash).not_to include(:audience_help)
    end

    context 'when used audience_help' do
      before { game_question.add_audience_help }

      it 'contains audience_help' do
        expect(game_question.help_hash).to include(:audience_help)
      end

      it 'includes correct answer key' do
        expect(game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      end
    end
  end

  describe '#add_friend_call' do
    it 'returns empty before use' do
      expect(game_question.help_hash).not_to include(:friend_call)
    end

    context 'when used friend_call' do
      before { game_question.add_friend_call }

      it 'contains friend_call' do
        expect(game_question.help_hash).to include(:friend_call)
      end

      it 'returns a string' do
        expect(game_question.help_hash[:friend_call]).instance_of?(String)
      end

      it 'returns correct answer key letter' do
        expect(game_question.help_hash[:friend_call]).to match /.*B/
      end
    end
  end
end
