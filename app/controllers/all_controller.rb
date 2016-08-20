class AllController < ApplicationController
  cattr_accessor :stored_cookies
  self.stored_cookies = {}

  def clear
    self.class.stored_cookies = {}
    head :ok
  end

  def all
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Origin'] = ENV['ALLOW']
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    case kicked
      when RestClient::Response
        store_cookie(kicked.cookies)
        kicked.cookies.each do |k, v|
          cookies[k] = v
        end
        begin
          render json: JSON.parse(kicked.body), status: kicked.code
        rescue
          render plain: kicked.body, status: kicked.code
        end
      when RestClient::InternalServerError
        render json: JSON.parse(kicked.response.body), status: kicked.response.code
      when RestClient::BadRequest
        render json: JSON.parse(kicked.response.body), status: kicked.response.code
      else
        render json: JSON.parse(kicked.response.body), status: kicked.response.code
    end
  end

  private

  def request_id
    # because session.id == nil in a request with OPTIONS
    1
  end

  def store_cookie(val)
    self.class.stored_cookies[request_id] = val
  end

  def stored_cookie
    self.class.stored_cookies[request_id] || {}
  end

  def kicked
    @kicked ||= begin
      if posting?
        RestClient.send(method, target, posted, {cookies: stored_cookie})
      else
        RestClient.send(method, queried, {cookies: stored_cookie})
      end
    rescue => e
      e
    end
  end

  def posting?
    method != 'get' && method != 'options'
  end

  def path
    params[:path]
  end

  def posted
    params.dup.permit!.to_h.tap do |posted|
      posted.delete(:controller)
      posted.delete(:action)
      posted.delete(:path)
    end
  end

  def method
    request.method.downcase
  end

  def target
    Pathname(ENV['TARGET']).join(path).to_s
  end

  def queried
    URI(target).tap { |uri|
      uri.query = posted.to_param
    }.to_s
  end
end
