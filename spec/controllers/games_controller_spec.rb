require 'rails_helper'
# Сразу подключим наш модуль с вспомогательными методами
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { FactoryBot.create(:user) }
  # админ
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'Anon' do
    # Аноним не может смотреть игру
    it 'kicks from #show' do
      # Вызываем экшен
      get :show, id: game_w_questions.id
      # Проверяем ответ
      expect(response.status).not_to eq(200) # статус ответа не равен 200 OK
      expect(response).to redirect_to(new_user_session_path) # Devise должен отправить на логин
      expect(flash[:alert]).to be # Во flash должно быть сообщение об ошибке
    end
  end

  # группа тестов на экшены контроллера, доступных залогиненным юзерам
  context 'Usual user' do
    # перед каждым тестом в группе
    before(:each) { sign_in user } # логиним юзера user с помощью спец. Devise метода sign_in

    # юзер может создать новую игру
    it 'creates game' do
      # сперва накидаем вопросов, из чего собирать новую игру
      generate_questions(15)

      post :create
      game = assigns(:game) # вытаскиваем из контроллера поле @game

      expect(game.finished?).to be(false) # проверяем состояние этой игры
      expect(game.user).to eq(user)
      expect(response).to redirect_to(game_path(game)) # и редирект на страницу этой игры
      expect(flash[:notice]).to be
    end

    # юзер видит свою игру
    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game) # вытаскиваем из контроллера поле @game

      expect(game.finished?).to be(false)
      expect(game.user).to eq(user)
      expect(response.status).to eq(200) # должен быть ответ HTTP 200
      expect(response).to render_template('show') # и отрендерить шаблон show
    end

    # юзер отвечает на игру корректно - игра продолжается
    it 'answers correct' do
      # передаем параметр params[:letter]
      letter = game_w_questions.current_game_question.correct_answer_key

      put :answer, id: game_w_questions.id, letter: letter
      game = assigns(:game)

      expect(game.finished?).to be(false)
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy # удачный ответ не заполняет flash
    end

    # проверка, что не может посмотреть чужую игру
    it '#show alien game' do
      # создаем новую игру, юзер не прописан, будет создан фабрикой новый
      alien_game = FactoryBot.create(:game_with_questions)

      # пробуем зайти на эту игру текущим залогиненным user
      get :show, id: alien_game.id

      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    it '#takes money' do
      game_w_questions.update_attribute(:current_level, 2)
      put :take_money, id: game_w_questions.id
      game = assigns(:game)

      expect(game.finished?).to be(true)
      expect(game.prize).to eq(200)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be

      user.reload
      expect(user.balance).to eq(200)
    end
  end
end
