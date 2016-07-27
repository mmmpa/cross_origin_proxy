require 'uri'

class AllController < ApplicationController
  cattr_accessor :stored_cookies

  def all
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Origin'] = 'http://localhost:8080'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    p kicked
    case kicked
      when RestClient::Response
        store_cookie(kicked.cookies)

        begin
          render json: JSON.parse(kicked.body), status: kicked.code and return
        rescue
          render plain: kicked.body, status: kicked.code and return
        end
      when RestClient::InternalServerError
        render head: :internal_server_error and return
      when RestClient::BadRequest
        render head: :bad_request and return
      else
        render plain: kicked and return
    end
  end

  private

  def store_cookie(val)
    stored_cookies[request_id] = val
  end

  def stored_cookie
    stored_cookies[request_id]
  end

  def stored_cookies
    self.class.stored_cookies ||= {}
  end

  def request_id
    session[:request_id] ||= SecureRandom.uuid
  end

  def kicked
    p stored_cookie.to_h
    @kicked = begin
      if method == 'get' || method == 'options'
        uri = URI(target)
        uri.query = posted.to_param
        RestClient.send(method, uri.to_s, {cookies: stored_cookie})
      else
        RestClient.send(method, target, posted, {cookies: stored_cookie})
      end
    rescue => e
      p e
    end
  end

  def path
    params[:path]
  end

  def posted
    params.dup.permit!.to_h.tap do |posted|
      posted.delete(:controller)
      posted.delete(:action)
      posted.delete(:path).to_s
    end
  end

  def method
    request.method.downcase
  end

  def target
    p Pathname(ENV['TARGET']).join(path).to_s
  end
end
