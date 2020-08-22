class CreateCoffeeshops < ActiveRecord::Migration[6.0]
  def change
    create_table :coffeeshops do |t|
      t.string :name
      t.string :address
      t.float :rating
      t.string :yelp_url
      t.string :image_url
      t.string :phone_number, default: "None"
      t.belongs_to :search
      t.timestamps
    end
  end
end
