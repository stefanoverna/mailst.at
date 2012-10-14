class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
