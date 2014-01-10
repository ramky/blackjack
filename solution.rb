#!/usr/bin/env ruby

def calculate_total(cards)
  # cards come in like this - ['S', 'K'],['C', '3']
  total = 0
  array = cards.map{|a| a[1]}
  array.each do |value|
    if value == 'A'
      total += 11
    elsif value.to_i == 0
      total += 10
    else
      total += value.to_i
    end
  end

  # Correct for Aces
  array.select{|e| e == 'A'}.count.times do
    total -= 10 if total > WIN_SCORE
  end

  total
end

def cards_to_string(cards)
  str_array = []
  cards.each do |suit, card|
    str_array << ( CARDS.key?(card) ? CARDS[card] : card ) + " of #{SUITS[suit]}"
  end
  "[#{str_array.join(', ')}]"
end

def show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)
  puts
  puts "#{player_name} has #{cards_to_string(player_cards)}, for a total of #{player_total}"
  puts "Dealer has #{cards_to_string(dealer_cards)}, for a total of #{dealer_total}"  
end

SUITS = {
  'H' => 'Hearts',
  'D' => 'Diamonds',
  'S' => 'Spades',
  'C' => 'Clubs'
}

CARDS = {
  'J' => 'Jack',
  'Q' => 'Queen',
  'K' => 'King',
  'A' => 'Ace'
}

WIN_SCORE = 21
DEALER_CUTOFF = 17

suits = %w[H D S C]
cards = %w[2 3 4 5 6 7 8 9 10 J Q K A]

print "What is the player's name? "
player_name = gets.chomp.downcase.capitalize
puts "Hello #{player_name}, Welcome to Blackjack!"

prompt_another_game = false
answer = 'y'

while true && answer == 'y'
  puts
  prompt_another_game = false
  deck = suits.product cards
  deck.shuffle!

  player_cards = []
  dealer_cards = []

  player_cards << deck.pop
  dealer_cards << deck.pop
  player_cards << deck.pop
  dealer_cards << deck.pop

  dealer_total = calculate_total(dealer_cards)
  player_total = calculate_total(player_cards)

  # Show Cards

  puts "Dealer showing #{dealer_cards[0]}"
  puts "#{player_name} has #{cards_to_string(player_cards)}, for a total of #{player_total}"
  puts 

  if player_total == WIN_SCORE
    if dealer_total == WIN_SCORE
      puts "Would you believe it? It's a tie!"
    else
      puts "#{player_name} hit blackjack! #{player_name} wins!"
    end
    prompt_another_game = true
  end

  while player_total < WIN_SCORE && !prompt_another_game
    print "What would you like to do? Press h to hit or s to stay. "
    input = gets.chomp.downcase
    unless %w[h s].include?(input)
      puts "Error: You must enter h or s."
      next
    end

    # Stay
    if input == 's'
      break
    end

    # Hit
    new_card = deck.pop
    player_cards << new_card
    player_total = calculate_total(player_cards)

    puts "Dealing new card to #{player_name}."
    puts "#{player_name} now has #{cards_to_string(player_cards)}, for a total of #{player_total}"
    puts "Dealer showing #{dealer_cards[0]}"

    if player_total == WIN_SCORE
      show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)
      puts "#{player_name} hit blackjack! #{player_name} wins!"
      prompt_another_game = true
    elsif player_total > WIN_SCORE
      show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)
      puts "#{player_name} busted!"
      prompt_another_game = true
    end
  end

  # Dealer's turn
  if dealer_total == WIN_SCORE && !prompt_another_game
    show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)
    puts "Dealer hit blackjack! #{player_name} loses!"
    prompt_another_game = true
  end

  while dealer_total < DEALER_CUTOFF && !prompt_another_game
    # Hit
    new_card = deck.pop
    dealer_cards << new_card
    dealer_total = calculate_total(dealer_cards)

    puts "Dealing new card to dealer."

    if dealer_total == WIN_SCORE
      show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)  
      puts "Dealer hit blackjack!  #{player_name} loses!"
      prompt_another_game = true
    elsif dealer_total > WIN_SCORE
      show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)
      puts "Dealer busted! #{player_name} wins!"
      prompt_another_game = true
    end
  end

  # Compare hands
  unless prompt_another_game
    show_cards(player_cards, dealer_cards, player_total, dealer_total, player_name)

    if dealer_total > player_total
      puts "#{player_name} loses."
    elsif player_total > dealer_total
      puts "#{player_name} wins."
    else
      puts "Would you believe it? It's a tie!"
    end
  end

  # If prompt_another_game is set correctly, the control should reach here
  while true
    print "Do you want to play another game[y/n]? "
    answer = gets.chomp.downcase
    unless %w[y n].include?(answer)
      puts "Error: You must enter y or n."
      next    
    else
      break
    end
  end
end
