require "sinatra/base"
require 'logger'

# Load custom environment variables
load 'env.rb' if File.exists?('env.rb')

class QuadbaseClient < Sinatra::Base
  enable :sessions

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def pretty_json(json)
      JSON.pretty_generate(json)
    end

    def signed_in?
      !session[:access_token].nil?
    end
  end

  logger = Logger.new(STDOUT)

  def client(token_method = :post)
    OAuth2::Client.new(
      ENV['OAUTH2_CLIENT_ID'],
      ENV['OAUTH2_CLIENT_SECRET'],
      :site         => ENV['SITE'] || "http://localhost:3000",
      :token_method => token_method,
    )
  end

  def access_token
    OAuth2::AccessToken.new(client, session[:access_token], :refresh_token => session[:refresh_token])
  end

  def redirect_uri
    ENV['OAUTH2_CLIENT_REDIRECT_URI']
  end

  get '/' do
    erb :home
  end

  get '/sign_in' do
    # scope = params[:scope] || "public"
    # redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => scope)
    redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri)
  end

  get '/sign_out' do
    session[:access_token] = nil
    redirect '/'
  end

  get '/callback' do
    new_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
    session[:access_token]  = new_token.token
    session[:refresh_token] = new_token.refresh_token
    redirect '/'
  end

  get '/refresh' do
    new_token = access_token.refresh!
    session[:access_token]  = new_token.token
    session[:refresh_token] = new_token.refresh_token
    redirect '/'
  end

  # get '/explore/:api' do
  #   raise "Please call a valid endpoint" unless params[:api]
  #   begin
  #     response = access_token.get("/api/#{params[:api]}/d1", {:headers => {'Accept' => 'application/vnd.quadbase.v1'}})
  #     @json = JSON.parse(response.body)
  #     erb :explore, :layout => !request.xhr?
  #   rescue OAuth2::Error => @error
  #     erb :error, :layout => !request.xhr?
  #   end
  # end

  get '/explore/*' do

    @endpoint = params[:splat].first
  
    raise "Please call a valid endpoint" unless @endpoint
    begin
      response = access_token.get("/api/#{@endpoint}", {:headers => {'Accept' => 'application/vnd.quadbase.v1'}})
      @json = JSON.parse(response.body)
      erb :explore, :layout => !request.xhr?
    rescue OAuth2::Error => @error
      erb :error, :layout => !request.xhr?
    end
  end

end
