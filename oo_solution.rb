#!/usr/bin/env ruby

class Card
  attr_accessor :suit, :face_value
  
  def initialize(suit, face_value)
    @suit = suit
    @face_value = face_value
  end

  def to_s
    "#{face_value} of #{humanize_suit}"
  end

  def humanize_suit
    case suit
      when 'H' then 'Hearts'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
      when 'C' then 'Clubs' 
    end
  end
end

class Deck
  attr_accessor :cards
  
  def initialize
    @cards = []
    %w[H D S C].each do |suit|
      %w[2 3 4 5 6 7 8 9 J Q K A].each do |face_value|
        @cards << Card.new(suit, face_value)
      end
    end
    scramble!
  end

  def scramble!
    cards.shuffle!
  end

  def deal_one
    cards.pop 
  end

  def size
    cards.size
  end
end

module Hand
  def show_hand
    puts "---- #{name}'s Hand ----"
    puts "[#{cards.join(', ')}]"
    puts "Total is #{total}"
  end

  def total
    face_values = cards.map{ |card| card.face_value }

    total = 0
    face_values.each do |value|
      if value == 'A'
        total += 11
      else
        total += (value.to_i == 0 ? 10 : value.to_i)
      end
    end

    # Correct for Aces
    face_values.select{ |value| value == "A" }.count.times do
      break if total <= Blackjack::WIN_SCORE
      total -= 10
    end

    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::WIN_SCORE
  end
end

class Player
  include Hand
  attr_accessor :name, :cards


  def initialize(name)
    @name = name
    @cards = []
  end
end

class Dealer
  include Hand
  attr_accessor :name, :cards

  def initialize
    @name = 'Dealer'
    @cards = []
  end

  def show_flop
    puts "---- Dealer's Hand ----"
    puts "[Hidden, #{cards[1]}]"    
  end
end

class Blackjack
  attr_accessor :deck, :player, :dealer

  WIN_SCORE = 21
  DEALER_CUTOFF = 17
  
  def initialize
    @deck = Deck.new
    @player = Player.new('Ram')
    @dealer = Dealer.new
  end

  def set_player_name
    puts "What's your name?"
    player.name = gets.chomp
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)      
  end

  def show_flop
    player.show_hand
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total == WIN_SCORE
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack.  #{player.name} loses."
      else
        puts "Congratulations, you hit blackjack. #{player.name} wins."
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted.  #{player.name} loses."
      else
        puts "Sorry, #{player.name} busted. #{player.name} loses."
      end
      play_again?      
    end
  end

  def player_turn
    puts "#{player.name}'s turn."

    blackjack_or_bust?(player)
    while !player.is_busted?
      print "What would you like to do? Press h to hit or s to stay. "
      input = gets.chomp.downcase
      unless %w[h s].include?(input)
        puts "Error: You must enter h or s."
        next
      end
      if input == "s"
        puts "#{player.name} chose to stay."
        break
      end
      # Hit
      new_card = deck.deal_one
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now: #{player.total}"

      blackjack_or_bust?(player)
    end
    puts "#{player.name} stays at #{player.total}."
  end

  def dealer_turn
    puts "Dealer's turn."

    blackjack_or_bust?(dealer)
    while dealer.total < DEALER_CUTOFF
      new_card = deck.deal_one
      puts "Dealing card to Dealer: #{new_card}"
      dealer.add_card(new_card)
      puts "Dealer's total is now: #{dealer.total}"
      blackjack_or_bust?(dealer)
    end
    puts "Dealer stays at #{dealer.total}."
  end

  def who_won?
    if player.total > dealer.total
      puts "Congratulations, #{player.name} wins."
    elsif player.total < dealer.total
      puts "Sorry, #{player.name} loses."
    else
      puts "It's a tie"
    end
    play_again?
  end

  def play_again?
    print "Do you want to play another game[y/n]? "
    answer = gets.chomp.downcase
    if answer == 'y'
      puts "Starting new game..."
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      start
    else
      puts "Goodbye!"
      exit
    end
  end

  def start
    set_player_name
    deal_cards
    show_flop
    player_turn
    dealer_turn
    who_won?
  end
end

game = Blackjack.new
game.start
