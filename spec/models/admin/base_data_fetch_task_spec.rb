# == Schema Information
#
# Table name: admin_data_fetch_tasks
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
require 'rails_helper'

RSpec.describe Admin::BaseDataFetchTask, type: :model do
  it { is_expected.to belong_to(:chat).class_name(Ai::Chat.name).optional }
  it { is_expected.to belong_to(:target) }

  specify do
    expect(described_class.new).to define_enum_for(:status).
      with_values(requested: 'requested', fetched: 'fetched', failed: 'failed', reviewed: 'reviewed').
      with_default(:requested).
      backed_by_column_of_type(:string)
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:base_admin_data_fetch_task)).to be_valid
    end
  end
end
