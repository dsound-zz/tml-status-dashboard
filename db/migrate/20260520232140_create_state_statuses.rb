class CreateStateStatuses < ActiveRecord::Migration[7.2]
  def change
    create_table :state_statuses do |t|
      t.references :state, null: false, foreign_key: true
      t.string :status
      t.datetime :planned_outage_start
      t.datetime :planned_outage_end
      t.string :outage_reason
      t.integer :response_time_ms
      t.decimal :uptime_30d, precision: 5, scale: 2
      t.datetime :last_checked_at

      t.timestamps
    end
  end
end
