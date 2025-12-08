class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.float :rating
      t.string :yelp_url
      t.string :image_url
      t.string :phone_number

      t.timestamps
    end
  end
end
