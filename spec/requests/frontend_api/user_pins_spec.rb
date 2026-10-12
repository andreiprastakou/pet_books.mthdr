# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/user_pins' do
  let(:reader) { create(:user) }

  before { sign_in_frontend_user!(reader) }

  describe 'GET /' do
    subject(:send_request) { get '/api/user_pins.json', headers: authorization_header }

    it 'returns the current user pins in case-insensitive alphabetical order' do
      ada = create(:author, fullname: 'ada lovelace')
      grace = create(:author, fullname: 'Grace Hopper')
      other_author = create(:author, fullname: 'Other Person')
      dune = create(:series, name: 'dune')
      earthsea = create(:series, name: 'Earthsea')
      alpha = create(:book, title: 'Alpha', year_published: 1965, authors: [ada, grace])
      zebra = create(:book, title: 'zebra', year_published: 2001, authors: [ada])
      someone_else = create(:user)

      create(:user_pin, user: reader, entity: grace)
      create(:user_pin, user: reader, entity: ada)
      create(:user_pin, user: someone_else, entity: other_author)
      create(:user_pin, user: reader, entity: earthsea)
      create(:user_pin, user: reader, entity: dune)
      create(:user_pin, user: reader, entity: zebra)
      create(:user_pin, user: reader, entity: alpha)
      create(:user_pin, user: someone_else, entity: create(:book, title: 'Hidden'))

      send_request

      expect(response).to be_successful
      expect(json_response[:authors].pluck(:fullname)).to eq(['ada lovelace', 'Grace Hopper'])
      expect(json_response[:series].pluck(:name)).to eq(%w[dune Earthsea])
      expect(json_response[:books]).to eq(
        [
          {
            id: alpha.id,
            title: 'Alpha',
            year: 1965,
            authors: Book.find(alpha.id).author_names_label
          },
          {
            id: zebra.id,
            title: 'zebra',
            year: 2001,
            authors: 'ada lovelace'
          }
        ]
      )
    end

    it 'returns empty lists when the user has no pins' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(authors: [], books: [], series: [])
    end

    context 'with pins_code' do
      let(:owner) { create(:user) }
      let(:sharing) { create(:user_pins_sharing, user: owner) }
      let(:author) { create(:author, fullname: 'Shared Author') }

      before { create(:user_pin, user: owner, entity: author) }

      it 'returns the shared user pins' do
        create(:user_pin, user: reader, entity: create(:author, fullname: 'Mine'))

        get '/api/user_pins.json', params: { pins_code: sharing.code }, headers: authorization_header

        expect(response).to be_successful
        expect(json_response[:authors].pluck(:fullname)).to eq(['Shared Author'])
      end

      it 'returns empty lists for an unknown code' do
        get '/api/user_pins.json', params: { pins_code: 'f' * 16 }, headers: authorization_header

        expect(response).to be_successful
        expect(json_response).to eq(authors: [], books: [], series: [])
      end
    end
  end
end
