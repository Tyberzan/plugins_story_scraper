# name: discourse-buildnet
# about: A plugin to synchronize Discourse with Buildnet
# version: 0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-buildnet

register_asset 'stylesheets/buildnet.scss'

after_initialize do
  require_dependency 'application_controller'
  
  module ::DiscourseBuildnet
    PLUGIN_NAME = "discourse-buildnet"
    
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseBuildnet
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
  require_relative 'lib/discourse_buildnet/engine'
  require_relative 'lib/discourse_buildnet/buildnet_syncer'
  
  DiscourseBuildnet::Engine.routes.draw do
    get '/' => 'discourse_buildnet#index'
    post '/sync_topic' => 'discourse_buildnet#sync_topic'
    post '/sync_user' => 'discourse_buildnet#sync_user'
  end
  
  Discourse::Application.routes.append do
    mount ::DiscourseBuildnet::Engine, at: '/buildnet'
  end
  
  # Add an admin route for the plugin
  add_admin_route 'buildnet.title', 'buildnet'
  
  # Event handlers for syncing
  on(:topic_created) do |topic|
    Jobs.enqueue(:sync_topic_to_buildnet, topic_id: topic.id) if SiteSetting.buildnet_enabled
  end
  
  on(:topic_edited) do |topic|
    Jobs.enqueue(:sync_topic_to_buildnet, topic_id: topic.id) if SiteSetting.buildnet_enabled
  end
  
  on(:user_created) do |user|
    Jobs.enqueue(:sync_user_to_buildnet, user_id: user.id) if SiteSetting.buildnet_enabled
  end
  
  on(:user_updated) do |user|
    Jobs.enqueue(:sync_user_to_buildnet, user_id: user.id) if SiteSetting.buildnet_enabled
  end
end 