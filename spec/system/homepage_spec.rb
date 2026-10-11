# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Homepage' do
  before do
    create(:cover_design, :default)
    create(:user, email: 'reader@example.com', password: 'password123')
  end

  it 'shows a pre-created book with its author' do
    author = create(:author, fullname: 'Ursula K. Le Guin')
    book = create(:book, title: 'The Left Hand of Darkness', authors: [author], year_published: 1969)

    visit '/login'
    fill_in 'Email', with: 'reader@example.com'
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    expect(page).to have_css('.book-case', text: book.title)
    # Author names stay title-case in the DOM; cover CSS uppercases them for display,
    # and Cuprite matches against that visible text.
    expect(page).to have_css('.book-case', text: /#{Regexp.escape(author.fullname)}/i)
  end
end
