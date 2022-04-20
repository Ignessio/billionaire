require 'rails_helper'
require 'support/my_spec_helper'

RSpec.feature 'USER looks at other user page', type: :feature do
  let(:vasya) { create(:user, name: 'Vasya', balance: 0) }
  let(:masha) { create(:user, name: 'Masha', balance: 500) }

  let!(:games) do [
    create(:game, user: masha, current_level: 0, created_at: Time.parse('19.04.2022, 10:00')),
    create(:game, user: masha, current_level: 5, created_at: Time.parse('19.04.2022, 11:00'), finished_at: Time.parse('19.04.2022, 11:10'), prize: 500)
    ]
  end

  before { login_as vasya }

  scenario "Vasya watches Masha's page" do
    visit '/'

    expect(page).to have_content 'Masha'

    click_link 'Masha'

    expect(page).to have_content 'Billionaire'
    expect(page).to have_content 'Vasya - 0 ₽'
    expect(page).to have_content 'Новая игра'
    expect(page).to have_content 'Выйти'

    expect(page).to have_current_path "/users/#{masha.id}"
    expect(page).not_to have_content 'Сменить имя и пароль'
    expect(page).to have_content 'Masha'

    expect(page).to have_content '#'
    expect(page).to have_content 'Дата'
    expect(page).to have_content 'Вопрос'
    expect(page).to have_content 'Выигрыш'
    expect(page).to have_content 'Подсказки'


    expect(page).to have_content 'в процессе'
    expect(page).to have_content 'деньги'
    expect(page).to have_content '19 апр., 10:00'
    expect(page).to have_content '19 апр., 11:00'
    expect(page).to have_content '5'
    expect(page).to have_content '500 ₽'

    expect(page).to have_content '50/50'
  end
end
