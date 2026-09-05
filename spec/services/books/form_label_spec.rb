# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::FormLabel do
  describe '.call' do
    subject(:result) { described_class.call(book) }

    let(:book) { build_stubbed(:book, literary_form: literary_form, genres: book_genres) }
    let(:literary_form) { 'novel' }
    let(:book_genres) { [] }

    it { is_expected.to eq('a novel') }

    context 'with one genre' do
      let(:book_genres) { [build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'fantasy'))] }

      it { is_expected.to eq('a fantasy novel') }
    end

    context 'with multiple genres' do
      let(:book_genres) do
        [
          build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'fantasy')),
          build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'horror')),
          build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'mystery')),
        ]
      end

      it { is_expected.to eq('a fantasy, horror, and mystery novel') }
    end

    context 'with a genre from GENRE_NAMES' do
      let(:book_genres) { [build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'scifi'))] }

      it { is_expected.to eq('a sci-fi novel') }
    end

    context 'with an unmapped codified genre name' do
      let(:book_genres) { [build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'hard_boiled'))] }

      it { is_expected.to eq('a hard boiled novel') }
    end

    context 'when the phrase starts with a vowel sound' do
      let(:book_genres) { [build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'epic'))] }

      it { is_expected.to eq('an epic novel') }
    end

    {
      'novella' => 'a novella',
      'short' => 'a short story',
      'short_story' => 'a short story',
      'poem' => 'a poem',
      'play' => 'a play',
      'comics' => 'a comic',
      'non_fiction' => 'a non-fiction work',
    }.each do |form, expected|
      context "with literary_form #{form.inspect}" do
        let(:literary_form) { form }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with an unknown literary form' do
      let(:literary_form) { 'audio_drama' }

      it { is_expected.to eq('an audio drama') }
    end

    context 'when literary_form is nil' do
      let(:literary_form) { nil }

      it { is_expected.to eq('') }

      context 'with genres' do
        let(:book_genres) { [build_stubbed(:book_genre, genre: build_stubbed(:genre, name: 'fantasy'))] }

        it { is_expected.to eq('a fantasy') }
      end
    end
  end
end
