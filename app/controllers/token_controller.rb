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
      params[:refresh_token] = result.refresh_token
      params[:expires_in] = result.expires_in
      params[:x_refresh_token_expires_in] = result.x_refresh_token_expires_in
      params[:access_token] = result.access_token
      params[:host_uri] = @hostURL.to_s
    else
      render html: '<div>Your State is not matched, consider it hacked.<div>'.html_safe
    end
  end

  def edit
    result = refresh_token
    params[:updated_refresh_token] = result.refresh_token
    params[:updated_expires_in] = result.expires_in
    params[:updated_x_refresh_token_expires_in] = result.x_refresh_token_expires_in
    params[:updated_access_token] = result.access_token
    params[:host_uri] = @hostURL.to_s
  end

  private

  def refresh_token
    load_config
    oauth_client.token.refresh_tokens(params[:id])
  end

  def exchange_code_for_token
    oauth_client.token.get_bearer_token(@code)
  end

  def load_config
    config = YAML.load_file(Rails.root.join('config/config.yml'))
    @hostURL = config["Settings"]["host_uri"]
    @client_id = config['OAuth2']['client_id']
    @client_secret = config['OAuth2']['client_secret']
    @scope = IntuitOAuth::Scopes::ACCOUNTING
    @redirect_uri = config["Settings"]["redirect_uri"]
    @state = config["Settings"]["state"]
  end

  def construct_baseUrl
    load_config
    oauth_client.code.get_auth_uri([@scope], @state)
  end

  def oauth_client
    IntuitOAuth::Client.new(@client_id, @client_secret, @redirect_uri, 'sandbox')
  end
end
