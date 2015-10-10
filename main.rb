require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do
  def calculate_total(cards) # cards is [["H", "3"], ["D", "J"], ... ]
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    #correct for Aces
    arr.select{|element| element == "A"}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def card_image(card) # ['H', '4']
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def play_again?
    session[:bet] = nil
    session[:turn] = "nobody"
    if session[:money] <= 0
      @play_again = false
      @error += "<br><strong>#{session[:player_name]} is bankrupt.  No more for you</strong>"
    else
      @play_again = true
    end
  end

  def winner!(msg)
    @show_hit_or_stay_buttons = false
    session[:money] += session[:bet]
    @winner = "<strong>#{session[:player_name]} wins!</strong> #{msg}" 
    play_again?
  end

  def loser!(msg)    
    @show_hit_or_stay_buttons = false
    session[:money] -= session[:bet]
    @loser = "<strong>#{session[:player_name]} loses.</strong> #{msg}"
    play_again?
  end

  def tie!(msg)
    @show_hit_or_stay_buttons = false
    @winner = "<strong>It's a tie!</strong> #{msg}"
    play_again?
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name]
      redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name]
  session[:money] = 500
  session[:bet] = nil
  redirect '/game'
end

get '/game' do
  if session[:bet].nil?
    redirect '/bet'
  end
  session[:turn] = "player"

  # create a deck and put it in session
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle! # [ ['H', '9'], ['C', 'K'] ... ]

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  redirect '/game/player/hit'
end

get '/game/player/hit' do
  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("It looks like #{session[:player_name]} busted at #{player_total}.")
  end

  erb :game, :layout => false
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  # decision tree
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN_HIT #17, 18, 19, 20
    # dealer stays
    redirect '/game/compare'
  else
    # dealer hits
    @show_dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:player_name]} and the dealer stayed at #{player_total}.")
  end
  session[:turn] = "dealer"
  erb :game
end

get '/game_over' do
  erb :game_over
end

get '/bet' do
  @money = session[:money]
  erb :bet
end

post '/bet' do
  if params[:bet].to_i <= session[:money] && params[:bet].to_i > 0
    session[:bet] = params[:bet].to_i
  elsif params[:bet].to_i == 0
    @money = session[:money]
    @zero_bet = true
    halt erb :bet
  else
    @bet_maxed_out = true
    @money = session[:money]
    halt erb :bet
  end
  redirect '/game'
end


