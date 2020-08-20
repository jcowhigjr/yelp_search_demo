class AddSearchIdToCoffeeshops < ActiveRecord::Migration[6.0]
  def change
    add_column :coffeeshops, :search_id, :integer
  end
end
