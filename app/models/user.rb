class User < ApplicationRecord
  has_many :messages
  validates :name, presence: true, length: { maximum: 15 }

  def auto_user_delete
    last_month = Date.today.prev_month
    User.destroy_all(updated_at: last_month.in_time_zone.all_month)
  end
end
