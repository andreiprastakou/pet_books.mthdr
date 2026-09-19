# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::InfoFetchers::Wikidata::Api::AuthorWorksFetcher do
  describe '#fetch' do
    subject(:result) { described_class.new(entity_id).fetch }

    let(:entity_id) { 'Q23434' }

    def binding_for(qid, label:, type: 'book')
      {
        'work' => { 'type' => 'uri', 'value' => "http://www.wikidata.org/entity/#{qid}" },
        'workLabel' => { 'xml:lang' => 'en', 'type' => 'literal', 'value' => label },
        'publicationDate' => {
          'datatype' => 'http://www.w3.org/2001/XMLSchema#dateTime',
          'type' => 'literal',
          'value' => '1984-01-01T00:00:00Z'
        },
        'typeLabel' => { 'xml:lang' => 'en', 'type' => 'literal', 'value' => type },
        'languageLabel' => { 'xml:lang' => 'en', 'type' => 'literal', 'value' => 'English' }
      }
    end

    def sparql_body(bindings)
      {
        'head' => { 'vars' => %w[work workLabel publicationDate typeLabel languageLabel] },
        'results' => { 'bindings' => bindings }
      }.to_json
    end

    let(:sparql_response_bindings) do
      [
        binding_for('Q43361', label: 'The Books of Blood', type: 'book series'),
        binding_for('Q43361', label: 'The Books of Blood', type: 'written work')
      ]
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      allow_any_instance_of(described_class).to receive(:sleep) # rubocop:disable RSpec/AnyInstance
      stub_request(:post, described_class::SPARQL_URL)
        .with(
          headers: {
            'User-Agent' => Admin::InfoFetchers::Wikidata::Api::BaseCaller::USER_AGENT,
            'Accept' => 'application/sparql-results+json'
          }
        )
        .to_return(status: 200, body: sparql_body(sparql_response_bindings))
    end

    it 'returns normalized, de-duplicated works for the author Q-ID' do
      expect(result).to eq(
        [
          {
            'work' => 'Q43361',
            'work_label' => 'The Books of Blood',
            'publication_date' => '1984-01-01T00:00:00Z',
            'type_label' => 'book series, written work',
            'language_label' => 'English'
          }
        ]
      )
      expect(
        a_request(:post, described_class::SPARQL_URL).with do |req|
          body = URI.decode_www_form(req.body.to_s).to_h
          query = body['query'].to_s
          body['format'] == 'json' &&
            query.include?('?work wdt:P50 wd:Q23434') &&
            described_class::EXCLUDED_TYPES.all? { |type| query.include?("wd:#{type}") } &&
            query.include?('?work wdt:P629 ?editionOf') &&
            query.include?('LIMIT 100') &&
            query.include?('OFFSET 0')
        end
      ).to have_been_made
    end

    context 'when results span multiple pages' do
      before do
        stub_const("#{described_class}::PAGE_SIZE", 2)
        page1 = [binding_for('Q1', label: 'Work One'), binding_for('Q2', label: 'Work Two')]
        page2 = [binding_for('Q3', label: 'Work Three')]

        stub_request(:post, described_class::SPARQL_URL)
          .to_return(
            { status: 200, body: sparql_body(page1) },
            { status: 200, body: sparql_body(page2) }
          )
      end

      it 'fetches iteratively and concatenates pages' do
        expect(result.map { |row| row['work'] }).to eq(%w[Q1 Q2 Q3])
        expect(
          a_request(:post, described_class::SPARQL_URL).with do |req|
            URI.decode_www_form(req.body.to_s).to_h['query'].to_s.include?('OFFSET 0')
          end
        ).to have_been_made
        expect(
          a_request(:post, described_class::SPARQL_URL).with do |req|
            URI.decode_www_form(req.body.to_s).to_h['query'].to_s.include?('OFFSET 2')
          end
        ).to have_been_made
      end
    end

    context 'when given a wiki path' do
      let(:entity_id) { '/wiki/Q23434' }

      it 'normalizes and fetches works' do
        expect(result.first['work']).to eq('Q43361')
      end
    end

    context 'when the id is blank' do
      let(:entity_id) { '  ' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:post, described_class::SPARQL_URL)).not_to have_been_made
      end
    end

    context 'when the service returns an error' do
      before do
        stub_request(:post, described_class::SPARQL_URL).to_return(status: 500)
      end

      it 'retries with a randomized cooldown then returns nil' do
        fetcher = described_class.new(entity_id)
        allow(fetcher).to receive(:sleep)
        allow(fetcher).to receive(:rand).and_return(1.5)

        expect(fetcher.fetch).to be_nil
        expect(fetcher).to have_received(:sleep).with(1.5).exactly(described_class::MAX_ATTEMPTS - 1).times
        expect(a_request(:post, described_class::SPARQL_URL))
          .to have_been_made.times(described_class::MAX_ATTEMPTS)
      end
    end

    context 'when the service fails once then succeeds' do
      before do
        stub_request(:post, described_class::SPARQL_URL)
          .to_return(
            { status: 500 },
            { status: 200, body: sparql_body(sparql_response_bindings) }
          )
      end

      it 'retries and returns the successful result' do
        fetcher = described_class.new(entity_id)
        allow(fetcher).to receive(:sleep)

        expect(fetcher.fetch.first['work']).to eq('Q43361')
        expect(fetcher).to have_received(:sleep).once
        expect(a_request(:post, described_class::SPARQL_URL)).to have_been_made.twice
      end
    end

    context 'when there are no bindings' do
      let(:sparql_response_bindings) { [] }

      it 'returns an empty array' do
        expect(result).to eq([])
      end
    end
  end
end
