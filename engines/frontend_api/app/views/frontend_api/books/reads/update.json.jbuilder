# frozen_string_literal: true

json.book_id @book.id
json.read @read
json.included_work_ids @included_work_ids if @included_work_ids.present?
