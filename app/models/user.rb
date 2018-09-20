class User < ApplicationRecord
  has_many :messages
  validates :name, presence: true, length: { maximum: 15 }

  def auto_user_delete
  end

  def test
    puts "test"
  end
end
