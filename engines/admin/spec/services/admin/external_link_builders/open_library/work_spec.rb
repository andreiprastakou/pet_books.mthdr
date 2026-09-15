# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExternalLinkBuilders::OpenLibrary::Work do
  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '/works/OL42413123W' => 'https://openlibrary.org/works/OL42413123W',
      'OL42413123W' => 'https://openlibrary.org/works/OL42413123W',
      'https://openlibrary.org/works/OL42413123W' => 'https://openlibrary.org/works/OL42413123W',
      'https://openlibrary.org/works/OL42413123W.json' => 'https://openlibrary.org/works/OL42413123W'
    }.each do |input, expected|
      context "with #{input.inspect}" do
        let(:identificator) { input }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with a blank identificator' do
      let(:identificator) { '  ' }

      it { is_expected.to be_nil }
    end
  end
end
