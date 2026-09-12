# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::Isfdb do
  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '3537436' => 'https://www.isfdb.org/cgi-bin/title.cgi?3537436',
      'https://www.isfdb.org/cgi-bin/title.cgi?3537436' => 'https://www.isfdb.org/cgi-bin/title.cgi?3537436'
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
