class Entree < ApplicationRecord
  belongs_to :journee_observation

  URGENTURIES_OPTIONS = ["", "X", "XX", "XXX"].freeze
  FUITES_OPTIONS = ["", "X", "XX", "XXX"].freeze

  validates :heure, presence: true
  validates :commentaires, length: { maximum: 10 }
  validates :urgenturies, inclusion: { in: URGENTURIES_OPTIONS }, allow_nil: true
  validates :fuites, inclusion: { in: FUITES_OPTIONS }, allow_nil: true

  after_save :recalculer_intervalles
  after_destroy :recalculer_intervalles

  private

  def recalculer_intervalles
    journee_observation.recalculer_intervalles!
  end
end
