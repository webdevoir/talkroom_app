class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :room_tags, dependent: :destroy

  def auto_room_delete
    yesterday = Date.today.yesterday
    Room.destroy_all(updated_at: yesterday.in_time_zone.all_day)
  end

  scope :updated_at_between, -> from, to {
    if from.present? && to.present?
      where(updated_at: from..to)
    elsif from.present?
      where('updated_at >= ?', from)
    elsif to.present?
      where('updated_at <= ?', to)
    end
  }

end
