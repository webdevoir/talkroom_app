class ArticleMessage < ApplicationRecord
    include AttachmentUploader[:attachment]
    belongs_to :article

    def attachment_name=(name)
      @attachment_name = name
    end

    def attachment_name
      @attachment_name
    end
end
