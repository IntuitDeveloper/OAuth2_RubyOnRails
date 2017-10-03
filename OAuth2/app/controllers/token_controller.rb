require 'uri'
require 'net/http'
require 'openssl'
require 'yaml'
require "base64"
require 'json'

class TokenController < ApplicationController
  def index
    url = construct_baseUrl
    redirect_to url.to_s
  end

  def new
    load_config
    state = params[:state].to_s
    if(state == @state.to_s)
      @code = params[:code]
      #record your ReamID to your DB
      @realmID = params[:realmId]
      result = exchange_code_for_token
      params[:refresh_token] = result["refresh_token"]
      params[:expires_in] = result["expires_in"]
      params[:x_refresh_token_expires_in] = result["x_refresh_token_expires_in"]
      params[:access_token] = result["access_token"]
      params[:host_uri] = @hostURL.to_s
    else
      render html: '<div>Your State is not matched, consider it hacked.<div>'.html_safe
    end
  end

  def edit
    result = refresh_token
    params[:updated_refresh_token] = result["refresh_token"]
    params[:updated_expires_in] = result["expires_in"]
    params[:updated_x_refresh_token_expires_in] = result["x_refresh_token_expires_in"]
    params[:updated_access_token] = result["access_token"]
    params[:host_uri] = @hostURL.to_s
  end

  def refresh_token
    load_config
    url = URI(@exchangeURL)
    queryparams = {
      'grant_type' => @refresh_token_scope.to_s,
      'refresh_token' => params[:id].to_s
    }
    header_value = "Basic " + Base64.strict_encode64(@client_id.to_s + ":" + @client_secret.to_s)
    headers = {
      'Content-type' => "application/x-www-form-urlencoded",
      'Accept' => "application/json",
      'Authorization' => header_value
    }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # TO debug, enable the below Line
    #http.set_debug_output($stdout)
    req = Net::HTTP::Post.new(url, headers)
    req.set_form_data(queryparams, "&")
    response = http.request(req)
    hash_response = JSON.parse(response.body)
    return hash_response
  end

  def exchange_code_for_token
    url = URI(@exchangeURL)
    queryparams = {
      'code' => @code.to_s,
      'grant_type' => @grant_type.to_s,
      'redirect_uri' => @redirect_uri.to_s
    }
    header_value = "Basic " + Base64.strict_encode64(@client_id.to_s + ":" + @client_secret.to_s)
    headers = {
      'Content-type' => "application/x-www-form-urlencoded",
      'Accept' => "application/json",
      'Authorization' => header_value
    }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # TO debug, enable the below Line
    #http.set_debug_output($stdout)
    req = Net::HTTP::Post.new(url, headers)
    req.set_form_data(queryparams, "&")
    response = http.request(req)
    hash_response = JSON.parse(response.body)
    return hash_response
  end

  def load_config
    config = YAML.load_file(Rails.root.join('config/config.yml'))
    @hostURL = config["Settings"]["host_uri"]
    @baseURL = config["Constant"]["baseURL"]
    @exchangeURL = config["Constant"]["tokenURL"]
    @client_id = config['OAuth2']['client_id']
    @client_secret = config['OAuth2']['client_secret']
    @scope = config["Constant"]["scope"]
    @refresh_token_scope = config["Constant"]["resfresh_grant_type"]
    @redirect_uri = config["Settings"]["redirect_uri"]
    @state = config["Settings"]["state"]
    @response_type = config["Constant"]["response_type"]
    @grant_type = config['Constant']['grant_type']
  end

  def construct_baseUrl
    load_config
    uri = URI(@baseURL)
    query_params = Array.new
    query_params.push(["client_id", @client_id])
    query_params.push(["scope", @scope])
    query_params.push(["redirect_uri", @redirect_uri])
    query_params.push(["response_type", @response_type])
    query_params.push(["state", @state])
    #append query string
    query_params.each do |element|
      params = URI.decode_www_form(uri.query || "") << element
      uri.query = URI.encode_www_form(params)
    end
    return uri
  end

end
