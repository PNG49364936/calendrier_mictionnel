class JourneeObservation < ApplicationRecord
  has_many :entrees, dependent: :destroy

  validates :date_observation, presence: true, uniqueness: true

  scope :par_date, -> { order(date_observation: :desc) }

  def total_boissons
    entrees.sum(:volume_boisson)
  end

  def total_urine
    entrees.sum(:volume_urine)
  end

  def en_cours?
    date_observation == Date.current && heure_coucher.blank?
  end
end
