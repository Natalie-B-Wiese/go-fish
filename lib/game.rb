require_relative 'deck'

class Game
  attr_reader :players, :deck
  attr_accessor :current_player_index

  def initialize(player_objs)
    @players = player_objs
    @deck = Deck.new
    @current_player_index = 0
  end

  def start
    deck.shuffle
    deal
  end

  def request_deck_card(rank)
    if deck.empty?
      switch_turn
    else
      card_taken = deck.take_top_card
      if card_taken.rank == rank
        puts 'TODO: player received card they wanted'
      else
        puts 'TODO: give player their card'
        switch_turn
      end
    end
  end

  private

  def switch_turn
    self.current_player_index += 1
    self.current_player_index = 0 if current_player_index >= players.length
  end

  def deal
    cards_per_player = players.length <= 3 ? 7 : 5

    cards_per_player.times do
      players.each_with_index do |_, index|
        players[index].add_card(deck.take_top_card)
      end
    end
  end
end
