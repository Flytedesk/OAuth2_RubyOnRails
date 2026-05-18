class QboAccount < ApplicationRecord
  validates_uniqueness_of :singleton_key
  validate :singleton_key_must_be_zero

  def self.sole
    find_or_initialize_by(singleton_key: 0)
  end

  def singleton_key_must_be_zero
    errors.add(:singleton_key, 'Must be zero') unless singleton_key.zero?
  end
end
