class BuildnetSyncLog < ActiveRecord::Base
  validates_presence_of :entity_type, :entity_id, :action, :status
  
  def self.cleanup_old_logs
    where('created_at < ?', 30.days.ago).delete_all
  end
  
  def as_json(options = nil)
    {
      id: id,
      entity_type: entity_type,
      entity_id: entity_id,
      action: action,
      status: status,
      message: message,
      created_at: created_at
    }
  end
end 