require 'net/http'
require 'uri'
require 'json'

class BuildnetApiService
  attr_reader :last_error
  
  def initialize
    @api_url = SiteSetting.buildnet_api_url
    @api_key = SiteSetting.buildnet_api_key
    @last_error = nil
  end
  
  def test_connection
    response = api_request(:get, "ping")
    response && response["success"]
  rescue => e
    @last_error = e.message
    false
  end
  
  def sync_topic(topic)
    topic_data = {
      id: topic.id,
      title: topic.title,
      category: topic.category&.name,
      created_at: topic.created_at.iso8601,
      user_id: topic.user_id
    }
    
    response = api_request(:post, "topics", topic_data)
    
    if response && response["success"]
      log_sync(:topic, topic.id, :create, "success", "Topic synced successfully")
      true
    else
      error = response&.dig("error") || "Unknown error"
      log_sync(:topic, topic.id, :create, "failure", error)
      false
    end
  rescue => e
    log_sync(:topic, topic.id, :create, "failure", e.message)
    @last_error = e.message
    false
  end
  
  def sync_user(user)
    user_data = {
      id: user.id,
      username: user.username,
      name: user.name,
      email: user.email,
      created_at: user.created_at.iso8601
    }
    
    response = api_request(:post, "users", user_data)
    
    if response && response["success"]
      log_sync(:user, user.id, :create, "success", "User synced successfully")
      true
    else
      error = response&.dig("error") || "Unknown error"
      log_sync(:user, user.id, :create, "failure", error)
      false
    end
  rescue => e
    log_sync(:user, user.id, :create, "failure", e.message)
    @last_error = e.message
    false
  end
  
  private
  
  def api_request(method, endpoint, data = nil)
    uri = URI.parse("#{@api_url}/#{endpoint}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    
    request = case method
              when :get
                Net::HTTP::Get.new(uri.request_uri)
              when :post
                Net::HTTP::Post.new(uri.request_uri)
              end
    
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = data.to_json if data
    
    response = http.request(request)
    
    if response.code.to_i >= 200 && response.code.to_i < 300
      JSON.parse(response.body)
    else
      @last_error = "HTTP #{response.code}: #{response.body}"
      nil
    end
  rescue => e
    @last_error = e.message
    nil
  end
  
  def log_sync(entity_type, entity_id, action, status, message)
    BuildnetSyncLog.create!(
      entity_type: entity_type.to_s,
      entity_id: entity_id,
      action: action.to_s,
      status: status.to_s,
      message: message
    )
  end
end 