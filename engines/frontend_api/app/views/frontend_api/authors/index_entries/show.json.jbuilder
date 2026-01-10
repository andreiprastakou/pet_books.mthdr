# frozen_string_literal: true

json.partial! 'frontend_api/authors/index_entries/author', author: @author,
                                                           counts_by_author: { @author.id => @author.books.count }
