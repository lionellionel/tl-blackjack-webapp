require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_spleen888739fjkj' 
def show_hand(hand)
  suit_strings = {
    'C' => 'clubs',
    'H' => 'hearts',
    'D' => 'diamonds',
    'S' => 'spades'
  }
  face_strings = { '1' => '1', '2' => '2', '3' => '3', '4' => '4', '5' => '5', 
    '6' => '6', '7' => '7', '8' => '8', '9' => '9', '10' => '10', 'J' => 'jack',
    'Q' => 'queen', 'K' => 'king', 'A' => 'ace'}
  hand.map{ |card| "<img src=images/cards/#{suit_strings[card[0]]}_#{face_strings[card[1]]}.jpg >" }.join
end

def calculate_total(hand)
  faces_only = hand.map{ |card| card[1] }
  total = 0
  faces_only.each do |value| 
    #puts "calc on value #{value}"
    case
    when (2..10).include?(value.to_i)
      total += value.to_i
    when ['J','Q','K'].include?(value)
      total += 10
    when value == 'A'
      total += 11
    end
  end
  faces_only.count('A').times do
    total -= 10 if total > 21
  end
  total
end

get '/' do
  if session[:username]
    redirect '/game'
  else
    redirect '/get_username'
  end
end

get '/get_username' do
  erb :get_username
end

post '/get_username' do
  session[:username] = params[:username]
  redirect '/game'
end

post '/hit' do
  binding.pry
end

post '/stay' do
  'buh'
end



get '/game' do  
  suits = ['D', 'C', 'H', 'S']
  faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  
  session[:deck] = suits.product(faces).shuffle
  
  session[:dealer_hand] = []
  session[:user_hand] = []
  #deal
  2.times do
    session[:dealer_hand] << session[:deck].pop
    session[:user_hand] << session[:deck].pop
  end


  @user_total = calculate_total(session[:user_hand])
  @dealer_total = calculate_total(session[:dealer_hand])
  dealers_total = 0
  hit_or_stay = 0
  "um, hi"
  erb :hit_or_stay
  #user_total
end