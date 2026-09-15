# frozen_string_literal: true

class RenameAdminDataFetchTaskStiTypes < ActiveRecord::Migration[8.1]
  TYPE_MAP = {
    'Admin::AuthorBooksListParsingTask' => 'Admin::Tasks::AiAuthorWorksParse',
    'Admin::AuthorBooksListTask' => 'Admin::Tasks::AiAuthorWorksFetch',
    'Admin::BookSummaryTask' => 'Admin::Tasks::AiBookFetch',
    'Admin::LibraryThingSearchTask' => 'Admin::Tasks::LibraryThingBookSearch',
    'Admin::OpenLibraryAuthorFetchTask' => 'Admin::Tasks::OpenLibraryAuthorFetch',
    'Admin::OpenLibraryAuthorSearchTask' => 'Admin::Tasks::OpenLibraryAuthorSearch',
    'Admin::OpenLibraryFetchTask' => 'Admin::Tasks::OpenLibraryBookFetch',
    'Admin::OpenLibrarySearchTask' => 'Admin::Tasks::OpenLibraryBookSearch',
    'Admin::WikidataAuthorFetchTask' => 'Admin::Tasks::WikidataAuthorFetch',
    'Admin::WikidataAuthorSearchTask' => 'Admin::Tasks::WikidataAuthorSearch',
    'Admin::WikidataFetchTask' => 'Admin::Tasks::WikidataBookFetch',
    'Admin::WikidataSearchTask' => 'Admin::Tasks::WikidataBookSearch',
    'Admin::BaseDataFetchTask' => 'Admin::Tasks::BaseTask'
  }.freeze

  def up
    TYPE_MAP.each do |old_type, new_type|
      execute <<~SQL.squish
        UPDATE admin_data_fetch_tasks
        SET type = #{connection.quote(new_type)}
        WHERE type = #{connection.quote(old_type)}
      SQL
    end
  end

  def down
    TYPE_MAP.each do |old_type, new_type|
      execute <<~SQL.squish
        UPDATE admin_data_fetch_tasks
        SET type = #{connection.quote(old_type)}
        WHERE type = #{connection.quote(new_type)}
      SQL
    end
  end
end
