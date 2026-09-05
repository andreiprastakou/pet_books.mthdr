# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Homepage' do
  before do
    create(:cover_design, :default)
    basic_auth_as_admin!
  end

  it 'shows a pre-created book with its author' do
    author = create(:author, fullname: 'Ursula K. Le Guin')
    book = create(:book, title: 'The Left Hand of Darkness', authors: [author], year_published: 1969)

    visit root_path

    expect(page).to have_css('.book-case', text: book.title)
    # Author names stay title-case in the DOM; cover CSS uppercases them for display,
    # and Cuprite matches against that visible text.
    expect(page).to have_css('.book-case', text: /#{Regexp.escape(author.fullname)}/i)
  end
end
