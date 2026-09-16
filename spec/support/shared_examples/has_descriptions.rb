# frozen_string_literal: true

shared_examples 'has descriptions' do
  describe 'associations' do
    it { is_expected.to have_many(:descriptions).class_name(Description.name).dependent(:destroy) }
  end
end
