FactoryBot.define do
  factory :game do
    # связь с юзером
    association :user

    # Игра только начата, создаем объект с нужными полями
    finished_at { nil }
    current_level { 0 }
    is_failed { false }
    prize { 0 }

    # Фабрика :game создает объект Game без дочерних игровых вопросов, в такую
    # игру играть нельзя, поэтому мы расширяем эту фабрику, добавляя ещё одну:

    # Фабрика :game_with_questions наследует все поля от фабрики :game и
    # добавляет созданные вопросы.
    factory :game_with_questions do
      # Коллбэк: после того, как создали игру (:build вызывается до
      # сохранения игры в базу), добавляем 15 вопросов разной сложности.
      after(:build) { |game|
        15.times do |i|
          # factory_girl create - дергает соотв. фабрику
          # создаем явно вопрос с нужным уровнем
          q = create(:question, level: i)
          # создаем связанные game_questions с нужной игрой и вопросом
          create(:game_question, game: game, question: q)
        end
      }
    end
  end
end
