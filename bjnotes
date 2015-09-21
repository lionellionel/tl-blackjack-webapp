def show_hand(hand)
  hand.each{ |card| puts "#{card[1]} #{card[0]}" }
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
  #puts "total #{total}"
  #puts "faces only"
  #puts faces_only
  faces_only.count('A').times do
    total -= 10 if total > 21
  end
  total
end


suits = ['D', 'C', 'H', 'S']
faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

deck = suits.product(faces).shuffle

dealer_hand = []
user_hand = []
#deal
2.times do
  dealer_hand << deck.pop
  user_hand << deck.pop
end

#4.times{deck << ['X','A']}
#puts deck

user_total = calculate_total(user_hand)
dealers_total = 0
hit_or_stay = 0

#users turn
#while users_total < 21 do
until user_total > 21 || hit_or_stay == 2 do
  show_hand(user_hand)
  puts "total is #{user_total}"
  puts "Hit (1) or Stay (2) ?"
  hit_or_stay = gets.chomp.to_i
  until [1,2].include?(hit_or_stay) 
    puts "Invalid choice.  Enter 1 or 2"
    hit_or_stay = gets.chomp.to_i
  end
  break if hit_or_stay == 2
  user_hand << deck.pop
  puts "you got #{user_hand[user_hand.length-1]}"
  user_total = calculate_total(user_hand)
end

if user_total > 21
  puts "at #{user_total} -- YOU BUSTED"
  exit
end

dealer_total = calculate_total(dealer_hand)
until dealer_total > 16 do
  puts "dealer has #{show_hand(dealer_hand)}"
  dealer_hand << deck.pop
  dealer_total = calculate_total(dealer_hand)
end

puts "dealer got #{show_hand(dealer_hand)}"

if dealer_total > 21
  puts "at #{dealer_total} -- DEALER BUSTED"
  exit
end

case
when dealer_total == user_total
  puts "It's a tie, you both got #{dealer_total}"
when dealer_total > user_total
  puts "Dealer wins.  #{dealer_total} beats #{user_total}"
when user_total > dealer_total
  puts "User wins.  #{user_total} beats #{dealer_total}"
end

