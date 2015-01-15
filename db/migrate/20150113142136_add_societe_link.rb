class AddSocieteLink < ActiveRecord::Migration
  def up
  	add_column :trainers, :lien_societe, :string
  end
  def down
  	remove_column :trainers, :lien_societe
  end
end
