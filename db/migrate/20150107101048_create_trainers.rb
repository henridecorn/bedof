class CreateTrainers < ActiveRecord::Migration
  def change
    create_table :trainers do |t|
      t.string :siren
      t.string :sigle

      t.timestamps
    end
  end
end
