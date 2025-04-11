module DiscourseStoryBuilder
  class Engine < ::Rails::Engine
    engine_name DiscourseStoryBuilder::PLUGIN_NAME
    isolate_namespace DiscourseStoryBuilder
    
    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseStoryBuilder::Engine, at: '/story-builder'
      end
    end
  end
end 