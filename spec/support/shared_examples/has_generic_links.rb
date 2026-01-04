shared_examples 'has generic links' do
  describe 'associations' do
    it { is_expected.to have_many(:generic_links).class_name(GenericLink.name).dependent(:destroy) }
  end
end
