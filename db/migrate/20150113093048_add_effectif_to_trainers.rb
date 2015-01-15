class AddEffectifToTrainers < ActiveRecord::Migration
  def up
  	add_column :trainers, :effectif, :integer
  end
  def down
  	remove_column :trainers, :effectif
  end
end
