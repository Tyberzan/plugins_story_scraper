module Jobs
  class SyncToBuildnet < ::Jobs::Scheduled
    every 1.hour
    
    def execute(args)
      return unless SiteSetting.buildnet_enabled
      return unless SiteSetting.buildnet_sync_interval > 0
      
      # Only run if the configured interval has passed
      last_run = PluginStore.get('discourse_buildnet', 'last_sync_time')
      now = Time.now.utc
      
      if last_run.present?
        interval_minutes = SiteSetting.buildnet_sync_interval.to_i
        next_run = DateTime.parse(last_run).to_time + interval_minutes.minutes
        return if next_run > now
      end
      
      # Sync topics
      if SiteSetting.buildnet_sync_topics
        topics_to_sync = Topic.where('updated_at > ?', 24.hours.ago)
        
        # Filter by allowed categories if configured
        if SiteSetting.buildnet_allowed_categories.present?
          allowed_category_ids = SiteSetting.buildnet_allowed_categories.split("|").map(&:to_i)
          topics_to_sync = topics_to_sync.where(category_id: allowed_category_ids)
        end
        
        service = BuildnetApiService.new
        
        topics_to_sync.find_each do |topic|
          service.sync_topic(topic)
        end
      end
      
      # Sync users
      if SiteSetting.buildnet_sync_users
        users_to_sync = User.where('updated_at > ?', 24.hours.ago)
        
        service = BuildnetApiService.new
        
        users_to_sync.find_each do |user|
          service.sync_user(user)
        end
      end
      
      # Clean up old logs
      BuildnetSyncLog.cleanup_old_logs
      
      # Update last run time
      PluginStore.set('discourse_buildnet', 'last_sync_time', now.iso8601)
    end
  end
end 