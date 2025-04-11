module DiscourseStoryBuilder
  class StoryBuilderSyncer
    def self.sync_topic(topic)
      return unless SiteSetting.story_builder_enabled
      
      api_service = StoryBuilderApiService.new
      response = api_service.sync_topic(topic)
      
      BuildnetSyncLog.create(
        item_type: 'topic',
        item_id: topic.id,
        success: response[:success],
        message: response[:message]
      )
      
      response
    end
    
    def self.sync_user(user)
      return unless SiteSetting.story_builder_enabled
      
      api_service = StoryBuilderApiService.new
      response = api_service.sync_user(user)
      
      BuildnetSyncLog.create(
        item_type: 'user',
        item_id: user.id,
        success: response[:success],
        message: response[:message]
      )
      
      response
    end
  end
end 