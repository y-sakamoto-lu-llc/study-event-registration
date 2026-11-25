class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :registrations, dependent: :destroy
  has_many :participants, -> { merge(Registration.registered) }, through: :registrations, source: :user

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }

  def organized_by?(user)
    organizer == user
  end

  def registration_for(user)
    registrations.find_by(user: user)
  end
end
