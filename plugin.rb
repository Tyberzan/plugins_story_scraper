# name: discourse-story-scraper
# about: A plugin to scrape and manage stories for MerciStory
# version: 0.1
# authors: Tyberzan
# url: https://github.com/Tyberzan/plugins_story_scraper

register_asset 'stylesheets/buildnet.scss'

after_initialize do
  require_dependency 'application_controller'
  
  module ::DiscourseStoryBuilder
    PLUGIN_NAME = "discourse-story-scraper"
    
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseStoryBuilder
    end
  end
  
  # Load controllers
  require_relative 'app/controllers/discourse_buildnet_controller'
  
  # Load services
  require_relative 'app/services/buildnet_api_service'
  
  # Load jobs
  require_relative 'app/jobs/scheduled/sync_to_buildnet'
  require_relative 'app/jobs/regular/sync_topic_to_buildnet'
  require_relative 'app/jobs/regular/sync_user_to_buildnet'
  
  # Load models
  require_relative 'app/models/buildnet_sync_log'
  
  # Load lib files
  require_relative 'lib/discourse_story_builder/engine'
  require_relative 'lib/discourse_story_builder/story_builder_syncer'
  
  DiscourseStoryBuilder::Engine.routes.draw do
    get '/' => 'discourse_buildnet#index'
    post '/sync_topic' => 'discourse_buildnet#sync_topic'
    post '/sync_user' => 'discourse_buildnet#sync_user'
  end
  
  Discourse::Application.routes.append do
    mount ::DiscourseStoryBuilder::Engine, at: '/story-builder'
  end
  
  # Add an admin route for the plugin
  add_admin_route 'story_builder.title', 'story_builder'
  
  # Event handlers for syncing
  on(:topic_created) do |topic|
    Jobs.enqueue(:sync_topic_to_buildnet, topic_id: topic.id) if SiteSetting.story_builder_enabled
  end
  
  on(:topic_edited) do |topic|
    Jobs.enqueue(:sync_topic_to_buildnet, topic_id: topic.id) if SiteSetting.story_builder_enabled
  end
  
  on(:user_created) do |user|
    Jobs.enqueue(:sync_user_to_buildnet, user_id: user.id) if SiteSetting.story_builder_enabled
  end
  
  on(:user_updated) do |user|
    Jobs.enqueue(:sync_user_to_buildnet, user_id: user.id) if SiteSetting.story_builder_enabled
  end
end 