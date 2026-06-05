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
    unless deck.empty?
      card_taken = deck.take_top_card

      give_card_to_current_player(card_taken)

      # prevent it from switching turns
      return if card_taken.rank == rank

    end

    switch_turn
  end

  private

  def give_card_to_current_player(card)
    players[current_player_index].add_card(card)
  end

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
