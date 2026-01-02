# frozen_string_literal: true

# == Schema Information
#
# Table name: book_public_lists
# Database name: primary
#
#  id             :integer          not null, primary key
#  role           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  book_id        :integer          not null
#  public_list_id :integer          not null
#
# Indexes
#
#  index_book_public_lists_on_book_id                     (book_id)
#  index_book_public_lists_on_book_id_and_public_list_id  (book_id,public_list_id) UNIQUE
#  index_book_public_lists_on_public_list_id              (public_list_id)
#
# Foreign Keys
#
#  book_id         (book_id => books.id)
#  public_list_id  (public_list_id => public_lists.id)
#
FactoryBot.define do
  factory :book_public_list, class: 'BookPublicList'
end
