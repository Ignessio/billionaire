require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, is_admin: true) }
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  describe '#show' do
    context 'when anonymous user' do
      before { get :show, id: game_w_questions.id }

      it 'responses with not 200OK status' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to new session page' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a flash message' do
        expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
      end
    end

    context 'when signed in user' do
      before do
        sign_in user
        get :show, id: game_w_questions.id
      end

      let(:game) { assigns(:game) }

      it 'continues the game' do
        expect(game.finished?).to be(false)
        expect(game.status).to eq(:in_progress)
      end

      it 'shows the user of the game' do
        expect(game.user).to eq(user)
      end

      it 'responses with 200OK status' do
        expect(response.status).to eq(200)
      end

      it 'sets rendering game page' do
        expect(response).to render_template('show')
      end
    end

    context 'when signed in user tries not own game' do
      before do
        sign_in user
        alien_game = create(:game_with_questions)
        get :show, id: alien_game.id
      end

      it 'responses with not 200OK status' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to main page' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash message' do
        expect(flash[:alert]).to eq('Это не ваша игра!')
      end
    end
  end

  describe '#create' do
    context 'when anonymous user' do
      before { post :create }

      it 'responses with status not 200 OK' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to new session page' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a flash message' do
        expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
      end
    end

    context 'when signed in user' do
      before { sign_in user }

      context 'and starts a new game' do
        before do
          generate_questions(15)
          post :create
        end

        let(:game) { assigns(:game) }

        it 'starts a new game' do
          expect(game.finished?).to be(false)
          expect(game.status).to eq(:in_progress)
        end

        it 'assignes the game to user' do
          expect(game.user).to eq(user)
        end

        it 'redirects to new game page' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'sets a flash message' do
          expect(flash[:notice]).to be
        end
      end

      context 'and starts a second game' do
        it 'does not start' do
          expect(game_w_questions.finished?).to be(false)
          expect { post :create }.to change(Game, :count).by(0)

          game = assigns(:game)

          expect(game).to be_nil
          expect(response).to redirect_to(game_path(game_w_questions))
          expect(flash[:alert]).to eq('Вы еще не завершили игру')
        end
      end
    end
  end

  describe '#answer' do
    context 'when anonymous user' do
      before(:each) do
        letter = game_w_questions.current_game_question.correct_answer_key
        post :answer, id: game_w_questions.id, letter: letter
      end

      it 'responses with status not 200 OK' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to new session page' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a flash message' do
        expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
      end
    end

    context 'when signed in user' do
      before { sign_in user }

      context 'and answer is correct' do
        before do
          letter = game_w_questions.current_game_question.correct_answer_key
          put :answer, id: game_w_questions.id, letter: letter
        end

        let(:game) { assigns(:game) }

        it 'continues' do
          expect(game.finished?).to be(false)
        end

        it 'increases game level' do
          expect(game.current_level).to be > 0
        end

        it 'redirects to game page' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'does not set flash message' do
          expect(flash.empty?).to be(true)
        end
      end

      context 'and answer is incorrect' do
        before do
          put :answer, id: game_w_questions.id, letter: 'a'
        end

        let(:game) { assigns(:game) }

        it 'completes the game' do
        expect(game.finished?).to be(true)
        end

        it 'redirects to user page' do
        expect(response).to redirect_to(user_path(user))
        end

        it 'sets a flash message' do
        expect(flash[:alert]).to be
        end
      end
    end
  end

  describe '#take_money' do
    context 'when anonymous user' do
      before(:each) { put :take_money, id: game_w_questions.id }

      it 'responses with status not 200 OK' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to new session page' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a flash message' do
        expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
      end
    end

    context 'when signed in user' do
      before do
        sign_in user
        game_w_questions.update_attribute(:current_level, 2)
        put :take_money, id: game_w_questions.id
      end

      let(:game) { assigns(:game) }

      it 'completes the game' do
        expect(game.finished?).to be(true)
      end

      it 'set the prize' do
        expect(game.prize).to eq(200)
      end

      it 'redirects to user page' do
        expect(response).to redirect_to(user_path(user))
      end

      it 'shows warning message' do
        expect(flash[:warning]).to be
      end

      it 'updates user balance' do
        user.reload
        expect(user.balance).to eq(200)
      end
    end
  end

  describe '#help' do
    context 'when anonymous user' do
      before { put :help, id: game_w_questions.id }

      it 'responses with status not 200 OK' do
        expect(response.status).not_to eq(200)
      end

      it 'redirects to new session page' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a flash message' do
        expect(flash[:alert]).to eq('Вам необходимо войти в систему или зарегистрироваться.')
      end
    end

    context 'when signed in user' do
      before { sign_in user }

      it 'returns key empty' do
        expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
        expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
        expect(game_w_questions.current_game_question.help_hash[:friend_call]).not_to be
      end
      it 'returns not used help type' do
        expect(game_w_questions.fifty_fifty_used).to be false
        expect(game_w_questions.audience_help_used).to be false
        expect(game_w_questions.friend_call_used).to be false
      end

      context 'and uses fifty-fifty help' do
        before { put :help, id: game_w_questions.id, help_type: :fifty_fifty }

        let(:game) { assigns(:game) }

        it 'continues the game' do
          expect(game.finished?).to be (false)
          expect(game.status).to eq(:in_progress)
        end

        it 'sets key used' do
          expect(game.fifty_fifty_used).to be true
        end

        it 'returns the key' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to be
        end

        it 'returns array including correct answer key' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to include(game.current_game_question.correct_answer_key)
        end

        it 'returns answers' do
          expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq(2)
        end

        it 'redirects to game page' do
          expect(response).to redirect_to(game_path(game))
        end
      end

      context 'and uses audience-help help' do
        before { put :help, id: game_w_questions.id, help_type: :audience_help }

        let(:game) { assigns(:game) }

        it 'continues the game' do
          expect(game.finished?).to be (false)
          expect(game.status).to eq(:in_progress)
        end

        it 'sets key used' do
          expect(game.audience_help_used).to be true
        end

        it 'returns the key' do
          expect(game.current_game_question.help_hash[:audience_help]).to be
        end

        it 'returns array including correct answer key' do
          expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
        end

        it 'redirects to game page' do
          expect(response).to redirect_to(game_path(game))
        end
      end

      context 'and uses friend-call help' do
        before { put :help, id: game_w_questions.id, help_type: :friend_call }

        let(:game) { assigns(:game) }

        it 'continues the game' do
          expect(game.finished?).to be (false)
          expect(game.status).to eq(:in_progress)
        end

        it 'sets key used' do
          expect(game.friend_call_used).to be true
        end

        it 'confirmes existance of instance' do
          expect(game.current_game_question.help_hash[:friend_call]).to be
        end

        it 'returns the string' do
          expect(game.current_game_question.help_hash[:friend_call]).instance_of?(String)
        end

        it 'returns correct answer key letter' do
          expect(game.current_game_question.help_hash[:friend_call]).to match /.*D/
        end

        it 'redirects to game page' do
          expect(response).to redirect_to(game_path(game))
        end
      end
    end
  end
end
