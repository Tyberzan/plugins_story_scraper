module DiscourseBuildnet
  class BuildnetSyncer
    def self.sync_topic(topic_id)
      return unless SiteSetting.buildnet_enabled
      
      topic = Topic.find_by(id: topic_id)
      return if topic.nil?
      
      service = BuildnetApiService.new
      service.sync_topic(topic)
    end
    
    def self.sync_user(user_id)
      return unless SiteSetting.buildnet_enabled
      
      user = User.find_by(id: user_id)
      return if user.nil?
      
      service = BuildnetApiService.new
      service.sync_user(user)
    end
    
    def self.sync_all
      return unless SiteSetting.buildnet_enabled
      
      Jobs.enqueue(:sync_to_buildnet)
    end
  end
end 