require 'rails_helper'

RSpec.describe Admin::LinksHelper do
  describe '#admin_actions_dropdown' do
    subject(:result) do
      helper.admin_actions_dropdown do
        helper.content_tag(:li, 'item')
      end
    end

    it 'renders a Bootstrap dropdown labeled actions' do
      expect(result).to include('b-actions-dropdown-toggle')
      expect(result).to include('actions')
      expect(result).to include('dropdown-menu-end')
      expect(result).to include('item')
      expect(result).to include('data-bs-toggle="dropdown"')
    end
  end

  describe '#admin_dropdown_button_to' do
    subject(:result) do
      helper.admin_dropdown_button_to 'sync wiki views', '/wiki', method: :put, class: 'text-danger'
    end

    it 'wraps a dropdown-item action button in a list item' do
      expect(result).to start_with('<li>')
      expect(result).to include('dropdown-item')
      expect(result).to include('b-dropdown-item-action')
      expect(result).to include('text-danger')
      expect(result).to include('b-dropdown-item-form')
      expect(result).to include('sync wiki views')
    end
  end

  describe '#admin_dropdown_link_to' do
    subject(:result) { helper.admin_dropdown_link_to 'AI parse works', '/parse' }

    it 'wraps a dropdown-item link in a list item' do
      expect(result).to start_with('<li>')
      expect(result).to include('dropdown-item')
      expect(result).to include('b-dropdown-item-link')
      expect(result).to include('AI parse works')
      expect(result).to include('href="/parse"')
    end
  end

  describe '#admin_action_to' do
    subject(:result) do
      helper.admin_action_to 'search', '/search', data: { turbo_method: :post }, class: 'extra'
    end

    it 'renders a local-action styled control' do
      expect(result).to include('b-local-action')
      expect(result).to include('extra')
      expect(result).to include('search')
      expect(result).to include('data-turbo-method="post"')
    end
  end

  describe '#admin_nav_collections_link' do
    it 'returns the correct link' do
      expect(helper.admin_nav_collections_link).to eq(['Collections', admin_collections_path])
    end
  end

  describe '#admin_nav_collection_link' do
    let(:collection) { build(:collection, name: 'Collection A') }

    it 'returns a quoted collection name' do
      expect(helper.admin_nav_collection_link(collection)).to eq('"Collection A"')
    end

    context 'when the collection name is too long' do
      let(:collection) { build(:collection, name: 'A' * 50) }

      it 'keeps 20 chars' do
        expect(helper.admin_nav_collection_link(collection)).to eq(
          '"AAAAAAAAAAAAAAAAA..."'
        )
      end
    end
  end

  describe '#admin_repeatable_action_label' do
    let(:task) { build_stubbed(:wikipedia_book_fetch_task) }

    it 'returns the original label when history has no matching task' do
      expect(helper.admin_repeatable_action_label('fetch', Admin::Tasks::WikipediaBookFetch, tasks: [])).to eq('fetch')
    end

    it 'prefixes re- when a matching task exists' do
      expect(
        helper.admin_repeatable_action_label('fetch', Admin::Tasks::WikipediaBookFetch, tasks: [task])
      ).to eq('re-fetch')
    end

    it 'prefixes re- for multi-word labels' do
      fetch_task = build_stubbed(:open_library_book_fetch_task)
      expect(
        helper.admin_repeatable_action_label('fetch data', Admin::Tasks::OpenLibraryBookFetch, tasks: [fetch_task])
      ).to eq('re-fetch data')
    end
  end

  describe '#admin_external_link_to' do
    context 'with a book wikipedia link' do
      let(:book) { create(:book, wiki_url: 'https://en.wikipedia.org/wiki/The_Hobbit') }

      it 'includes page/view counts and a fetch link' do
        result = helper.admin_external_link_to(book, book.wikipedia_external_link)

        expect(result).to include(
          'wikipedia',
          'fetch',
          'b-local-action',
          admin_book_wikipedia_fetches_path(book)
        )
      end

      context 'when a wikipedia fetch task already exists in history' do
        it 'labels the action as re-fetch' do
          result = helper.admin_external_link_to(
            book,
            book.wikipedia_external_link,
            history_tasks: [build_stubbed(:wikipedia_book_fetch_task, target: book)]
          )

          expect(result).to include('re-fetch')
          expect(result).not_to include('>fetch<')
        end
      end
    end

    context 'with a series wikipedia link' do
      let(:series) { create(:series, wiki_url: 'https://en.wikipedia.org/wiki/The_Lord_of_the_Rings') }

      it 'includes page/view counts without a fetch link' do
        result = helper.admin_external_link_to(series, series.wikipedia_external_link)

        expect(result).to include('wikipedia')
        expect(result).not_to include('>fetch<')
        expect(result).not_to include('wikipedia_fetches')
      end
    end
  end
end
