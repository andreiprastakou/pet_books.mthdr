# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::LibraryThing do
  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '33363109' => 'https://www.librarything.com/work/33363109',
      '/work/33363109' => 'https://www.librarything.com/work/33363109',
      'https://www.librarything.com/work/33363109' => 'https://www.librarything.com/work/33363109'
    }.each do |input, expected|
      context "with #{input.inspect}" do
        let(:identificator) { input }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with a blank identificator' do
      let(:identificator) { nil }

      it { is_expected.to be_nil }
    end
  end
end
