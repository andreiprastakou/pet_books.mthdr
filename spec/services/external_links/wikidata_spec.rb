# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::Wikidata do
  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      'Q137179018' => 'https://www.wikidata.org/wiki/Q137179018',
      '/wiki/Q137179018' => 'https://www.wikidata.org/wiki/Q137179018',
      'https://www.wikidata.org/wiki/Q137179018' => 'https://www.wikidata.org/wiki/Q137179018'
    }.each do |input, expected|
      context "with #{input.inspect}" do
        let(:identificator) { input }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with a blank identificator' do
      let(:identificator) { '' }

      it { is_expected.to be_nil }
    end
  end
end
