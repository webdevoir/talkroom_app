class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :room_tags, dependent: :destroy

  def auto_room_delete
    yesterday = Date.today.yesterday
    Room.destroy_all(updated_at: yesterday.in_time_zone.all_day)
  end
end
