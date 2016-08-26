class AllController < ApplicationController
  def all
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Origin'] = ENV['ALLOW']
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization']
    
    respond_response(rest_response)
  end

  private

  def respond_response(rest_res)
    rest_res.cookies.each do |k, v|
      cookies[k] = v
    end
    render_safety(rest_res)
  end

  def render_safety(rest_res)
    begin
      render json: JSON.parse(rest_res.body), status: rest_res.code
    rescue
      render plain: rest_res.body, status: rest_res.code
    end
  end

  def rest_response
    @rest_response ||= begin
      if posting?
        RestClient.send(method, target, posted, {cookies: request.cookies})
      else
        RestClient.send(method, queried_uri, {cookies: request.cookies})
      end
    rescue => e
      e.response
    end
  end

  def posting?
    method != 'get' && method != 'options'
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
    Pathname(ENV['TARGET']).join(params[:path].to_s).to_s
  end

  def queried_uri
    URI(target).tap { |uri| uri.query = posted.to_param }.to_s
  end
end
