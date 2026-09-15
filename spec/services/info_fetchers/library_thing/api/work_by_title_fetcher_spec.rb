require 'rails_helper'

RSpec.describe InfoFetchers::LibraryThing::Api::WorkByTitleFetcher do
  describe '#fetch' do
    subject(:result) { described_class.new(title).fetch }

    let(:title) { 'The Hobbit' }
    let(:app_token) { ENV['LIBRARYTHING_APP_TOKEN'].presence || 'test-librarything-token' }
    let(:expected_url) do
      "https://www.librarything.com/api/#{app_token}/thingTitle/#{ERB::Util.url_encode(title)}"
    end
    let(:xml_body) do
      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <idlist>
          <title>The Hobbit</title>
          <link>https://www.librarything.com/work/14184045</link>
          <isbn>0261102664</isbn>
          <isbn>0345445600</isbn>
        </idlist>
      XML
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, expected_url)
        .with(headers: { 'User-Agent' => InfoFetchers::LibraryThing::Api::BaseCaller::USER_AGENT })
        .to_return(status: 200, body: xml_body, headers: { 'Content-Type' => 'application/xml' })
    end

    it 'returns the parsed LibraryThing response' do
      expect(result).to eq(
        'idlist' => {
          'title' => 'The Hobbit',
          'link' => 'https://www.librarything.com/work/14184045',
          'isbn' => %w[0261102664 0345445600]
        }
      )
    end

    context 'when the title is blank' do
      let(:title) { '  ' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, %r{librarything\.com})).not_to have_been_made
      end
    end

    context 'when the service returns an HTTP error' do
      before do
        stub_request(:get, expected_url).to_return(status: 503)
      end

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
