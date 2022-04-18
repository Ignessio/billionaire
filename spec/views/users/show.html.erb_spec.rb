require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe 'users/show', type: :view do
  context 'when user see own page' do
    before do
      user = assign(:user, build_stubbed(:user, name: 'Fedul'))
      allow(view).to receive(:current_user).and_return(user)
      assign(:games, [build_stubbed_list(:game, 1)])
      stub_template 'users/_game.html.erb' => 'Here is partial for <%= @user.name %> user game'

      render
    end

    it 'renders user name' do
      expect(rendered).to match 'Fedul'
    end

    it 'renders edit link button' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'renders partial' do
      expect(rendered).to match 'Here is partial for Fedul user game'
    end
  end

  context 'when user see not own page' do
    before do
      assign(:user, build_stubbed(:user, name: 'Boba'))

      render
    end

    it 'does not render edit link button' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end
