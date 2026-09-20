# == Schema Information
#
# Table name: admin_data_fetch_tasks
# Database name: primary
#
#  id                  :integer          not null, primary key
#  fetch_error_details :string
#  fetched_data        :json
#  input_data          :json
#  status              :string           not null
#  target_type         :string           not null
#  type                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_id             :integer
#  target_id           :integer          not null
#
# Indexes
#
#  index_admin_data_fetch_tasks_on_chat_id  (chat_id)
#  index_admin_data_fetch_tasks_on_target   (target_type,target_id)
#
# Foreign Keys
#
#  chat_id  (chat_id => ai_chats.id)
#
module Admin
  module Tasks
    # rubocop:disable-next Metrics/ClassLength
    class BaseTask < ApplicationRecord
      self.table_name = 'admin_data_fetch_tasks'

      TASK_TYPES = [
        'Admin::Tasks::AiAuthorWorksFetch',
        'Admin::Tasks::AiAuthorWorksParse',
        'Admin::Tasks::AiBookFetch',
        'Admin::Tasks::LibraryThingBookSearch',
        'Admin::Tasks::OpenLibraryAuthorFetch',
        'Admin::Tasks::OpenLibraryAuthorSearch',
        'Admin::Tasks::OpenLibraryBookFetch',
        'Admin::Tasks::OpenLibraryBookSearch',
        'Admin::Tasks::WikidataAuthorFetch',
        'Admin::Tasks::WikidataAuthorSearch',
        'Admin::Tasks::WikidataAuthorWorksFetch',
        'Admin::Tasks::WikidataBookFetch',
        'Admin::Tasks::WikidataBookSearch',
        'Admin::Tasks::WikipediaAuthorFetch',
        'Admin::Tasks::WikipediaBookFetch'
      ].freeze

      # Wikipedia → Wikidata → OpenLibrary → LibraryThing; fetch before search.
      BOOK_REVIEW_PRIORITY = [
        'Admin::Tasks::WikipediaBookFetch',
        'Admin::Tasks::WikidataBookFetch',
        'Admin::Tasks::WikidataBookSearch',
        'Admin::Tasks::OpenLibraryBookFetch',
        'Admin::Tasks::OpenLibraryBookSearch',
        'Admin::Tasks::LibraryThingBookSearch'
      ].freeze

      AUTHOR_REVIEW_PRIORITY = [
        'Admin::Tasks::WikipediaAuthorFetch',
        'Admin::Tasks::WikidataAuthorFetch',
        'Admin::Tasks::WikidataAuthorSearch',
        'Admin::Tasks::OpenLibraryAuthorFetch',
        'Admin::Tasks::OpenLibraryAuthorSearch'
      ].freeze

      belongs_to :chat, class_name: 'Admin::Ai::Chat', optional: true
      belongs_to :target, polymorphic: true

      enum :status, {
        requested: 'requested',
        fetched: 'fetched',
        failed: 'failed',
        rejected: 'rejected',
        verified: 'verified'
      }, default: :requested

      def self.review_priority_types_for(subject)
        case subject
        when ::Book, Admin::Book then BOOK_REVIEW_PRIORITY
        when ::Author, Admin::Author then AUTHOR_REVIEW_PRIORITY
        else []
        end
      end

      def self.pending_review_tasks_for(subject)
        priority = review_priority_types_for(subject)
        return [] if priority.empty?

        scope_for_review_subject(subject)
          .where(status: :fetched, type: priority)
          .to_a
          .sort_by { |task| [priority.index(task.type), task.id] }
      end

      def self.next_pending_review_for(subject, excluding: nil)
        tasks = pending_review_tasks_for(subject)
        tasks = tasks.reject { |task| task.id == excluding.id } if excluding
        tasks.first
      end

      def self.scope_for_review_subject(subject)
        owner_type, owner_id, identity_ids = review_subject_query_parts(subject)
        return none if owner_type.blank?

        where(target_type: owner_type, target_id: owner_id)
          .or(where(target_type: Admin::ExternalIdentity.name, target_id: identity_ids))
      end

      def self.review_subject_query_parts(subject)
        admin_class = review_subject_admin_class(subject)
        return [nil, nil, nil] unless admin_class

        [admin_class.superclass.name, subject.id, admin_class.cast(subject).external_identities.select(:id)]
      end
      private_class_method :review_subject_query_parts

      def self.review_subject_admin_class(subject)
        case subject
        when ::Book, Admin::Book then Admin::Book
        when ::Author, Admin::Author then Admin::Author
        end
      end
      private_class_method :review_subject_admin_class

      def enqueue_for_processing!
        Admin::DataFetchJob.perform_later(id)
      end

      def save_results!(data, chat: nil, errors: [])
        if errors.present?
          update!(status: :failed, chat: chat, fetched_data: data,
                  fetch_error_details: errors.map(&:message).join(', '))
        else
          self.fetched_data = data
          self.chat = chat
          self.status = fetched_data_normalized.blank? ? :rejected : :fetched
          save!
        end
      end

      def review_stage?
        fetched?
      end

      def fetched_data_normalized
        fetched_data || {}
      end

      # Book / Author this task should advance review for (via direct target or ExternalIdentity).
      def review_subject
        case target
        when ::Book, Admin::Book then Admin::Book.cast(target)
        when ::Author, Admin::Author then Admin::Author.cast(target)
        when Admin::ExternalIdentity then review_subject_for_identity(target)
        end
      end

      def review_subject_for_identity(identity)
        case identity.owner
        when ::Book, Admin::Book then Admin::Book.cast(identity.owner)
        when ::Author, Admin::Author then Admin::Author.cast(identity.owner)
        end
      end
    end
  end
end
