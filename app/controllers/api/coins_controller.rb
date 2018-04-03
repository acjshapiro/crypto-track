class Api::CoinsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_coin, only: [:show, :update, :destroy] 

  BASE_URL = 'https://api.coinmarketcap.com/v1/ticker/' 


  def index
    render json: current_user.coins 
  end

  def create
    # find out if coin exists
    cmc_id = params[:coin].downcase
    res = HTTParty.get("#{BASE_URL}#{cmc_id}")
    if coin =  Coin.create_by_cmc_id(res)
      watched =  WatchedCoin.find_or_create_by(coin_id: coin.id, user_id: current_user.id)
      watched.update(initial_price: coin.price) if watched.initial_price.nil?
    else
      render json: { errors: 'Coin Not Found' }, status: 422
    

  end

  def update
    # hijacking action to stop watching coins instead of creating another controller
    current_user.watched_coins.find_by(coin_id: @coin.id).destroy 
  end

  def destroy
    @coin.destroy 
  end

  def show
    render json: @coin 
  end
end
