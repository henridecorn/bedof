class AddDirigeantToTrainer < ActiveRecord::Migration
  def up
  	add_column :trainers, :sexe_dirigeant, :string
  	add_column :trainers, :nom_dirigeant, :string
  end
  def down
  	remove_column :trainers, :sexe_dirigeant
  	remove_column :trainers, :nom_dirigeant
  end
end
