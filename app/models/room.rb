class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :room_tags, dependent: :destroy

  def auto_room_delete
  end
end
