class CreateUserFavorites < ActiveRecord::Migration[6.0]
  def change
    create_table :user_favorites do |t|
      t.belongs_to :user
      t.belongs_to :coffeeshop
      t.timestamps
    end
  end
end
