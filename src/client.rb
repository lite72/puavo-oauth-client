require 'sinatra/base'
require 'haml'
require 'addressable/uri'
require 'net/http'
require 'uri'
require 'json'
require 'restclient'

class Client < Sinatra::Base

  # Predefined application identification data 
  set :redirect_uri, 'https://my.client.software/callback/'   # We choose, and tell Opinsys our redirect_uri
  set :login_base_uri, 'https://opinsys.fi/oauth/authorize'
  set :authorization_base_uri, 'https://opinsys.fi/oauth/token'
  set :puavo_rest_base, 'https://opinsys.fi/'

  set :client_id, 'oauth_client_id/09d25700-95cd-012f-6c73-5254010000e5'
  set :client_secret, '09d24230-95cd-012f-6c72-5254010000e5'

  # At first our resource owner is thrown here and she sees "Puavo login" button.
  # When the user clicks the login button he will be redirected to Puavo login page
  get '/' do
      uri = Addressable::URI.new
      @state = '123456789'
      uri.query_values = {
          :client_id => settings.client_id,
          :redirect_uri => settings.redirect_uri,
          :state => @state,
          :response_type => 'code',
          :approval_prompt => 'auto', # This value isn't currently used by Puavo
          :access_type => 'offline'   # This value isn't currently used by Puavo 
      }
      # This url (containing query params) is used for login link/button
      @login_url = settings.login_base_uri + '?' + uri.query 
      haml :hello
  end

  # After successful login Puavo throws our user here, along with parameters ( code, state ) 
  get '/callback/' do
    # We could optionally check that the state parameters is the same we generated in the first step
    #throw PuavoBehavingStrangelyOrManInTheMiddle if not params["state"].eql? @state

    # Here we parse authorization uri and add credentials into it
    uri = Addressable::URI.parse( settings.authorization_base_uri )
    # In our client_id slash is the only character that needs escaping when used as part of url
    uri.user= URI.escape( settings.client_id, "/" ) 
    uri.password= settings.client_secret

    # We try to obtain tokens by using authorization code
    begin
      res = RestClient.post uri.to_s,       {
        :grant_type => "authorization_code",
        :code => params["code"],
        :redirect_uri => settings.redirect_uri
      }.to_json, :content_type => :json, :accept => :json
    rescue Exception => e 
       @error = e.to_s
       haml :error
    end

    # Successful transaction gives us JSON containing tokens
    token_data = JSON::parse res 
    @@access_token = token_data["access_token"] 
    @@refresh_token = token_data["refresh_token"] 
    @@expires_in = token_data["expires_in"] 
    @@token_type = token_data["token_type"] # always 'Bearer' 

    # Now we can use the REST API and authorize requests with access token
    # 'GET oauth/whoami' REST request to Puavo with Authorization header
    begin
      res = RestClient.get settings.puavo_rest_base + "oauth/whoami", {
        :Authorization => "Bearer #{@@access_token}", 
        :accept => :json 
      }
    # Request error handling
    rescue Exception => e 
       @error = e.to_s
       haml :error
    end

    # Check response data validity and parse data. Exception is raised if there's a JSON parse error.
    begin
      @user_data = JSON::parse res  
      res
    rescue Exception => e
      @error = e.to_s
      haml :error
    end
  end
  
  get '/refresh_token' do
    uri = Addressable::URI.parse( settings.authorization_base_uri )
    # In our client_id slash is the only character that needs escaping when used as part of url
    uri.user = URI.escape( settings.client_id, "/" ) 
    uri.password = settings.client_secret

    begin
      res = RestClient.post uri.to_s,       {
        :grant_type => "refresh_token",
        :refresh_token => @@refresh_token,
      }.to_json, :content_type => :json, :accept => :json
    rescue Exception => e 
       @error = e.to_s
       haml :error
    end

    # Successful transaction gives us JSON containing tokens
    begin
      token_data = JSON::parse res 
      @@refresh_token = token_data["refresh_token"] 
      @@expires_in = token_data["expires_in"] 
      @@token_type = token_data["token_type"] # always 'Bearer' 
      @@access_token = token_data["access_token"] 
      # ... 
    rescue Exception => e
      @error = e.to_s
      haml :error
    end
  end
end
