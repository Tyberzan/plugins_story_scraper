module Jobs
  class SyncUserToBuildnet < ::Jobs::Base
    def execute(args)
      return unless SiteSetting.buildnet_enabled
      
      user_id = args[:user_id]
      return if user_id.blank?
      
      user = User.find_by(id: user_id)
      return if user.blank?
      
      service = BuildnetApiService.new
      service.sync_user(user)
    end
  end
end 