module Jobs
  class SyncTopicToBuildnet < ::Jobs::Base
    def execute(args)
      return unless SiteSetting.buildnet_enabled
      
      topic_id = args[:topic_id]
      return if topic_id.blank?
      
      topic = Topic.find_by(id: topic_id)
      return if topic.blank?
      
      # Check if the topic should be synced based on category
      if SiteSetting.buildnet_allowed_categories.present?
        allowed_category_ids = SiteSetting.buildnet_allowed_categories.split("|").map(&:to_i)
        return unless allowed_category_ids.include?(topic.category_id)
      end
      
      service = BuildnetApiService.new
      service.sync_topic(topic)
    end
  end
end 