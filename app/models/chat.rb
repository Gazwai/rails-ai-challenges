class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  has_many :messages, dependent: :destroy
end
