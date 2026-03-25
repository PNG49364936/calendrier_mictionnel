class AddIntervalleMictionnelToEntrees < ActiveRecord::Migration[7.1]
  def change
    add_column :entrees, :intervalle_mictionnel, :integer
  end
end
