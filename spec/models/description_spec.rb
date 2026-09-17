# frozen_string_literal: true

# == Schema Information
#
# Table name: descriptions
# Database name: primary
#
#  id           :integer          not null, primary key
#  owner_type   :string           not null
#  priority     :integer          default(0), not null
#  source_label :string
#  source_type  :string
#  text         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer          not null
#  source_id    :integer
#
# Indexes
#
#  index_descriptions_on_owner_type_and_owner_id_and_priority  (owner_type,owner_id,priority)
#  index_descriptions_on_source_type_and_source_id             (source_type,source_id)
#
require 'rails_helper'

RSpec.describe Description do
  subject(:description) { build(:description) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:source).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:owner_type) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to validate_numericality_of(:priority).only_integer }

    it 'has a valid factory' do
      expect(build(:description)).to be_valid
    end
  end

  describe '#summary_source' do
    subject(:result) { description.summary_source }

    let(:description) { build(:description, source_label: source_label, source_type: source_type) }
    let(:source_label) { nil }
    let(:source_type) { nil }

    context 'when source_label is present' do
      let(:source_label) { 'AI: Claude' }
      let(:source_type) { 'Admin::Tasks::OpenLibraryBookFetch' }

      it { is_expected.to eq('AI: Claude') }
    end

    context 'when source is an Open Library task' do
      let(:source_type) { 'Admin::Tasks::OpenLibraryBookFetch' }

      it { is_expected.to eq(ExternalResources::OPEN_LIBRARY) }
    end

    context 'when source is a Wikidata task' do
      let(:source_type) { 'Admin::Tasks::WikidataBookFetch' }

      it { is_expected.to eq(ExternalResources::WIKIDATA) }
    end

    context 'when source is a Wikipedia task' do
      let(:source_type) { 'Admin::Tasks::WikipediaBookFetch' }

      it { is_expected.to eq(ExternalResources::WIKIPEDIA) }
    end

    context 'when source has no mapped external resource' do
      let(:source_type) { 'Admin::Tasks::AiBookFetch' }

      it { is_expected.to be_nil }
    end
  end

  describe '#display_source_label' do
    subject(:result) { description.display_source_label }

    let(:description) { build(:description, source_label: source_label, source_type: source_type) }
    let(:source_label) { nil }
    let(:source_type) { nil }

    context 'when source_label is present' do
      let(:source_label) { 'AI: Claude' }

      it { is_expected.to eq('AI: Claude') }
    end

    context 'when source is an Open Library task' do
      let(:source_type) { 'Admin::Tasks::OpenLibraryBookFetch' }

      it { is_expected.to eq('Open Library') }
    end

    context 'when source has no mapped external resource' do
      let(:source_type) { 'Admin::Tasks::AiBookFetch' }

      it { is_expected.to be_nil }
    end
  end
end
