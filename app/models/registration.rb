class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, { registered: 0, cancelled: 1 }

  validates :user_id, uniqueness: { scope: :event_id }
end
