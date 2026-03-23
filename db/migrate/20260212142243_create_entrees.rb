class CreateEntrees < ActiveRecord::Migration[7.1]
  def change
    create_table :entrees do |t|
      t.references :journee_observation, null: false, foreign_key: true
      t.time :heure, null: false
      t.integer :volume_boisson
      t.integer :volume_urine
      t.string :urgenturies
      t.string :fuites
      t.string :commentaires, limit: 10

      t.timestamps
    end
  end
end
