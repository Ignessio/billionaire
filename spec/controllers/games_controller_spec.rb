require 'rails_helper'
# Сразу подключим наш модуль с вспомогательными методами
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) } # обычный пользователь
  let(:admin) { FactoryBot.create(:user, is_admin: true) } # админ
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) } # игра с прописанными игровыми вопросами

  # Группа тестов на анонимного юзера
  describe 'user not logged in (anonymous)' do
    context 'when tries to see a game' do
      # Аноним не может смотреть игру
      it 'kicks from #show action' do
        get :show, id: game_w_questions.id # Вызываем экшен

        expect(response.status).not_to eq(200) # статус ответа не равен 200 OK
        expect(response).to redirect_to(new_user_session_path) # Devise должен отправить на логин
        expect(flash[:alert]).to be # Во flash должно быть сообщение об ошибке
      end
    end

    context 'when tries to create new game' do
      it 'kicks from #create action' do
        post :create

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context 'when tries to answer a questioin' do
      it 'kicks from #answer action' do
        letter = game_w_questions.current_game_question.correct_answer_key
        post :answer, id: game_w_questions.id, letter: letter

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context 'when tries to take money' do
      it 'kicks from #take_money action' do
        put :take_money, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context 'when tries to take help' do
      it 'kicks from #help action' do
        put :help, id: game_w_questions.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

  end

  # группа тестов на экшены контроллера, доступных залогиненным юзерам
  context 'Usual user' do
    # перед каждым тестом в группе
    before(:each) { sign_in user } # логиним юзера user с помощью спец. Devise метода sign_in

    # юзер может создать новую игру
    it '#create game' do
      generate_questions(15) # сперва накидаем вопросов, из чего собирать новую игру

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
    it '#answer is correct' do
      # передаем параметр params[:letter]
      letter = game_w_questions.current_game_question.correct_answer_key

      put :answer, id: game_w_questions.id, letter: letter
      game = assigns(:game)

      expect(game.finished?).to be(false)
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be(true) # удачный ответ не заполняет flash
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

    it '#take_money' do
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

    # юзер не может создать вторую игру
    it 'tries to create second game' do
      expect(game_w_questions.finished?).to be(false)
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game)
      expect(game).to be_nil

      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end

    it '#answer is incorrect' do
      put :answer, id: game_w_questions.id, letter: 'a'
      game = assigns(:game)

      expect(game.finished?).to be(true)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be
    end
  end
end
