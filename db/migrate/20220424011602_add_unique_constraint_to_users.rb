class AddUniqueConstraintToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
    add_index :users, :name, unique: true
  end
end
