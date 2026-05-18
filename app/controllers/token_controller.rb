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
    if state == session[:state]
      @code = params[:code]
      #record your ReamID to your DB
      @realmID = params[:realmId]
      result = exchange_code_for_token
      @qbo_account = QboAccount.sole
      @qbo_account.update!(access_token: result.access_token, refresh_token: result.refresh_token)
      params[:expires_in] = result.expires_in
      params[:x_refresh_token_expires_in] = result.x_refresh_token_expires_in
      params[:host_uri] = @hostURL.to_s
    else
      render html: '<div>Your State is not matched, consider it hacked.<div>'.html_safe
    end
  end

  def edit
    @qbo_account = QboAccount.sole
    result = refresh_token
    @qbo_account.update!(access_token: result.access_token, refresh_token: result.refresh_token)
    params[:updated_expires_in] = result.expires_in
    params[:updated_x_refresh_token_expires_in] = result.x_refresh_token_expires_in
    params[:host_uri] = @hostURL.to_s
  end

  def destroy
    @qbo_account = QboAccount.sole
    @qbo_account.destroy!
    load_config
    params[:host_uri] = @hostURL.to_s
  end

  private

  def refresh_token
    load_config
    oauth_client.token.refresh_tokens(@qbo_account.refresh_token)
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
  end

  def construct_baseUrl
    load_config
    state = SecureRandom.uuid
    session[:state] = state
    oauth_client.code.get_auth_uri([@scope], state)
  end

  def oauth_client
    IntuitOAuth::Client.new(@client_id, @client_secret, @redirect_uri, 'sandbox')
  end
end
