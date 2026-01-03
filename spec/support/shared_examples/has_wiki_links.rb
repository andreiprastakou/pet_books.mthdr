shared_examples 'has wiki links' do
  describe 'associations' do
    it { is_expected.to have_many(:wiki_links).class_name(WikiLink.name).dependent(:destroy) }
  end

  describe 'before validation' do
    it 'builds wiki links from the wiki_url' do
      record.wiki_url = 'https://en.wikipedia.org/wiki/Test'
      expect { record.valid? }.to change { record.wiki_links.to_a }.from([]).to([kind_of(WikiLink)])
      expect(record.wiki_links[0]).to be_new_record
      expect(record.wiki_links[0].locale).to eq('en')
      expect(record.wiki_links[0].name).to eq('Test')
      expect(record.wiki_links[0].url).to eq('https://en.wikipedia.org/wiki/Test')
    end

    context 'without a wiki_url' do
      it 'does not build wiki links' do
        record.wiki_url = nil
        expect { record.valid? }.not_to change { record.wiki_links.to_a }.from([])
      end
    end

    context 'with a wiki_url that is not a valid wikipedia url' do
      it 'does not fail nor builds wiki links' do
        record.wiki_url = 'https://example.com/test'
        expect { record.valid? }.not_to change { record.wiki_links.to_a }.from([])
      end
    end
  end

  describe 'validations' do
    it 'checks the wiki_url format' do
      record.wiki_url = 'https://example.com/test'
      expect(record).not_to be_valid
      expect(record.errors[:wiki_url]).to include('is not a valid wikipedia url')

      record.wiki_url = 'https://en.wikipedia.org/wiki/Test'
      expect(record).to be_valid
    end
  end

  describe '#wiki_links_sum_views' do
    subject(:result) { record.wiki_links_sum_views }

    before do
      record.wiki_links << build(:wiki_link, views: 101)
      record.wiki_links << build(:wiki_link, views: 103)
      record.wiki_links << build(:wiki_link, views: nil)
    end

    it 'returns the sum of the views of the wiki links' do
      expect(result).to eq(101 + 103)
    end
  end
end
