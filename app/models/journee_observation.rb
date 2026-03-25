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

  # Recalcule l'intervalle mictionnel (en minutes) pour toutes les entrées
  # ayant un volume_urine. La 1ère miction n'a pas d'intervalle (nil).
  def recalculer_intervalles!
    mictions = entrees.where.not(volume_urine: [nil, 0]).order(:heure).to_a
    mictions.each_with_index do |entree, i|
      if i == 0
        entree.update_column(:intervalle_mictionnel, nil)
      else
        minutes = ((entree.heure - mictions[i - 1].heure) / 60).round.abs
        entree.update_column(:intervalle_mictionnel, minutes)
      end
    end
    # Les entrées sans urine n'ont pas d'intervalle
    entrees.where(volume_urine: [nil, 0]).update_all(intervalle_mictionnel: nil)
  end
end
