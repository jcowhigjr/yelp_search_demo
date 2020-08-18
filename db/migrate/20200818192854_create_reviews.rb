class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.string :content
      t.float :rating
      t.belongs_to :user
      t.belongs_to :coffeeshop
      t.timestamps
    end
  end
end
