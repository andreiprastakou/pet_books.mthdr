shared_examples 'has external links' do
  describe 'associations' do
    it { is_expected.to have_many(:external_links).class_name(ExternalLink.name).dependent(:destroy) }
  end
end
