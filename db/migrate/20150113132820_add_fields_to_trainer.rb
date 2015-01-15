class AddFieldsToTrainer < ActiveRecord::Migration
  def up
  	add_column :trainers, :denomination, :string
  	add_column :trainers, :adresse, :string
  	add_column :trainers, :code_postal, :string
  	add_column :trainers, :activite, :string
  	add_column :trainers, :forme_juridique, :string
  	add_column :trainers, :date_de_creation, :string
  end
  def down
  	remove_column :trainers, :denomination
  	remove_column :trainers, :adresse
  	remove_column :trainers, :code_postal
  	remove_column :trainers, :activite
  	remove_column :trainers, :forme_juridique
  	remove_column :trainers, :date_de_creation
  end
end
