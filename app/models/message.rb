class Message < ApplicationRecord
  include AttachmentUploader[:attachment]
  after_create_commit { MessageBroadcastJob.perform_later self }
  belongs_to :user
  belongs_to :room

  def attachment_name=(name)
    @attachment_name = name
  end

  def attachment_name
    @attachment_name
  end
end
