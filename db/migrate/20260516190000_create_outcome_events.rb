class CreateOutcomeEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :outcome_events do |t|
      t.references :user
      t.string :event_type, null: false
      t.json :payload, null: false, default: {}

      t.timestamps
    end

    add_index :outcome_events, :event_type
    add_index :outcome_events, :created_at
    add_index :outcome_events, [:event_type, :created_at]
    add_foreign_key :outcome_events, :users, on_delete: :nullify
  end
end
