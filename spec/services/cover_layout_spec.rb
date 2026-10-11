# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoverLayout do
  let(:anthology) do
    [
      'Adrian Tchaikovsky', 'Hal Wilson', 'Christopher Allen', 'Liane Merciel',
      'Noah Van Nguyen', 'Nick Horth', 'Anna Stephens', 'Matt Keefe'
    ]
  end

  describe '.title' do
    it 'leaves a title that fits on the default cover unchanged' do
      title = 'On the Shoulders of Giants and Other Stories'
      expect(described_class.title(title)).to eq(title)
    end

    it 'leaves a seventy-character title intact at the default size' do
      title = 'N' * 70
      expect(described_class.title(title, size: 'lg')).to eq(title)
    end

    it 'shortens a title that cannot fit the narrowest cover' do
      displayed = described_class.title('N' * 70, size: 'xs')
      expect(displayed.length).to be < 70
      expect(displayed).to end_with('...')
    end

    it 'breaks a shortened title on a word' do
      title = ('longword ' * 12).strip
      displayed = described_class.title(title, size: 'xs')
      body = displayed.delete_suffix('...')

      expect(displayed).to end_with('...')
      expect(title).to start_with(body)
      expect(body).not_to end_with(' ')
    end
  end

  describe '.author_line' do
    it 'returns nil when there are no names' do
      expect(described_class.author_line([])).to be_nil
    end

    it 'omits a byline that has too many or too-long names' do
      expect(described_class.author_line(anthology)).to be_nil
      expect(described_class.author_line(['Christopher Allen Williamson', 'Liane Merciel-Something'])).to be_nil
    end

    it 'keeps a short shared byline' do
      expect(described_class.author_line(['Hal Wilson', 'Matt Keefe'])).to eq(
        text: 'Hal Wilson, Matt Keefe', tight: false
      )
    end

    it 'always keeps a single author and tightens a name that would leave the cover' do
      expect(described_class.author_line(['Frank Herbert'])).to eq(text: 'Frank Herbert', tight: false)

      name = "Tchaikovsky#{'E' * 80}"
      expect(described_class.author_line([name])).to eq(text: name, tight: true)
    end
  end
end
