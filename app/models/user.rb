class User < ApplicationRecord
  has_many :messages
  validates :name, presence: true, length: { maximum: 15 }
end
