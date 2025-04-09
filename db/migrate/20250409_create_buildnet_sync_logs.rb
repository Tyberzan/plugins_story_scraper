class CreateBuildnetSyncLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :buildnet_sync_logs do |t|
      t.string :entity_type, null: false
      t.integer :entity_id, null: false
      t.string :action, null: false
      t.string :status, null: false
      t.text :message
      t.timestamps
    end
    
    add_index :buildnet_sync_logs, [:entity_type, :entity_id]
    add_index :buildnet_sync_logs, :created_at
  end
end 