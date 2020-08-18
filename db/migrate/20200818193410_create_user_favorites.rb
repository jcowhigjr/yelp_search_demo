class CreateUserFavorites < ActiveRecord::Migration[6.0]
  def change
    create_table :user_favorites do |t|
      t.integer :user_id
      t.string :coffeeshop_id
      t.string :integer

      t.timestamps
    end
  end
end
