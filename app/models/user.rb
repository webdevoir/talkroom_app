class User < ApplicationRecord
  has_many :messages
  has_many :chats
  validates :name, presence: true, length: { maximum: 15 }

  def auto_user_delete
    last_month = Date.today.prev_month
    User.destroy_all(updated_at: last_month.in_time_zone.all_month)
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
