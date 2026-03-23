class CreateJourneeObservations < ActiveRecord::Migration[7.1]
  def change
    create_table :journee_observations do |t|
      t.date :date_observation, null: false
      t.time :heure_lever
      t.time :heure_coucher

      t.timestamps
    end
  end
end
