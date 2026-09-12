# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::Goodreads do
  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '87596585' => 'https://www.goodreads.com/work/editions/87596585',
      '/work/editions/87596585' => 'https://www.goodreads.com/work/editions/87596585',
      'https://www.goodreads.com/work/editions/87596585' => 'https://www.goodreads.com/work/editions/87596585',
      'https://www.goodreads.com/work/editions/87596585-some-title' => 'https://www.goodreads.com/work/editions/87596585'
    }.each do |input, expected|
      context "with #{input.inspect}" do
        let(:identificator) { input }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with a blank identificator' do
      let(:identificator) { ' ' }

      it { is_expected.to be_nil }
    end
  end
end
