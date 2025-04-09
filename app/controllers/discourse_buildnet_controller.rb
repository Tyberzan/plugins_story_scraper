module DiscourseBuildnet
  class DiscourseBuildnetController < ::ApplicationController
    requires_plugin DiscourseBuildnet::PLUGIN_NAME
    
    before_action :ensure_logged_in
    before_action :ensure_admin, except: [:index]
    
    def index
      render json: { success: true }
    end
    
    def logs
      logs = BuildnetSyncLog.order(created_at: :desc).limit(100)
      render json: { logs: logs.map(&:as_json) }
    end
    
    def test_connection
      service = BuildnetApiService.new
      
      if service.test_connection
        render json: { success: true }
      else
        render json: { success: false, errors: service.last_error }, status: 422
      end
    end
    
    def sync_topic
      params.require(:topic_id)
      topic_id = params[:topic_id].to_i
      
      topic = Topic.find_by(id: topic_id)
      
      if topic.nil?
        render json: { success: false, errors: I18n.t("buildnet.errors.topic_not_found") }, status: 404
        return
      end
      
      Jobs.enqueue(:sync_topic_to_buildnet, topic_id: topic_id)
      
      render json: { success: true }
    end
    
    def sync_user
      params.require(:user_id)
      user_id = params[:user_id].to_i
      
      user = User.find_by(id: user_id)
      
      if user.nil?
        render json: { success: false, errors: I18n.t("buildnet.errors.user_not_found") }, status: 404
        return
      end
      
      Jobs.enqueue(:sync_user_to_buildnet, user_id: user_id)
      
      render json: { success: true }
    end
    
    def sync_all
      Jobs.enqueue(:sync_to_buildnet)
      
      render json: { success: true }
    end
  end
end 