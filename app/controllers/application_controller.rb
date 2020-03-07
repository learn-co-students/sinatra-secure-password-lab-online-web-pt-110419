require "./config/environment"
require "./app/models/user"
require "pry"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    if User.new(username: params[:username],password: params[:password]).save
      redirect to '/login'
    else
      redirect to '/failure'
    end
  end

  get '/account' do
    #binding.pry
    if logged_in?
      @user = current_user
    erb :account
    else
      redirect to "/failure"
    end
  end

  get '/withdraw' do
    #binding.pry
    if logged_in?
      @user = current_user
    erb :withdraw
    else
      redirect to "/failure"
    end
  end

  post '/withdraw' do
    if logged_in?
      @user = current_user
      if @user.balance < params[:withdrawal_amount].to_i
        redirect to "/no_funds"
      else
        @user.balance=@user.balance-params[:withdrawal_amount].to_i
        @user.save
        redirect to "/account"
      end
    else
      redirect to "/failure"
    end
  end

  get '/no_funds' do
    @user = current_user
    #binding.pry
    erb :not_enough_funds
  end

  get '/deposit' do
    #binding.pry
    if logged_in?
      @user = current_user
      erb :deposit
    else
      redirect to "/failure"
    end
  end

  post '/deposit' do
    if logged_in?
      @user = current_user
      @user.balance=@user.balance+params[:deposit_amount].to_i
      @user.save
      redirect to "/account"
    else
      redirect to "/failure"
    end
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect to "/account"
    else
      redirect to "/failure"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect to "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
end
