class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
