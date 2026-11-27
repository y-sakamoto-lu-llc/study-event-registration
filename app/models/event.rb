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

  def full?
    registrations.registered.count >= capacity
  end

  def accepting_registrations?
    Time.current <= (registration_deadline || starts_at)
  end

  # 参加登録する。登録できなかったときは、理由を errors[:base] に入れた未保存（または元の状態のまま）の登録を返す。
  # キャンセル済みの登録があれば、新しい行を作らずにその行を登録済みに戻す。
  def register(user)
    with_lock do
      registration = registrations.find_or_initialize_by(user: user)
      next registration if registration.persisted? && registration.registered?

      if !accepting_registrations?
        registration.errors.add(:base, "申込は締め切りました")
      elsif full?
        registration.errors.add(:base, "満席です")
      else
        registration.registered!
      end

      registration
    end
  end
end
