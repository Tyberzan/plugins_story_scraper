module DiscourseBuildnet
  class Engine < ::Rails::Engine
    engine_name DiscourseBuildnet::PLUGIN_NAME
    isolate_namespace DiscourseBuildnet
    
    config.after_initialize do
      # Initialize any engine-specific configuration here
    end
  end
end 