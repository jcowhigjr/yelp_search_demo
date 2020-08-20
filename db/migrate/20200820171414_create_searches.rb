class CreateSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :searches do |t|
      t.belongs_to :user
      t.string :query

      t.timestamps
    end
  end
end
