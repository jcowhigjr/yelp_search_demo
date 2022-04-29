class AddLatitudeToSearch < ActiveRecord::Migration[7.0]
  def change
    add_column :searches, :latitude, :decimal, precision: 16, scale: 6
  end
end
