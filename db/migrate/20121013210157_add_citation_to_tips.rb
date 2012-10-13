class AddCitationToTips < ActiveRecord::Migration
  def change
    add_column :tips, :citation, :string
  end
end
