class AddEmailToTrainers < ActiveRecord::Migration
  def up
  	add_column :trainers, :email_dirigeant, :string
  	add_column :trainers, :crawled_for_email, :boolean
  end
  def down
  	remove_column :trainers, :email_dirigeant
  	remove_column :trainers, :crawled_for_email
  end
end
