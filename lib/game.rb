require_relative 'deck'

class Game
  attr_reader :players, :deck

  def initialize(player_objs)
    @players = player_objs
    @deck = Deck.new
  end

  def start
    deck.shuffle
    deal
  end

  private

  def deal
    cards_per_player = players.length <= 3 ? 7 : 5

    cards_per_player.times do
      players.each_with_index do |_, index|
        players[index].add_card(deck.take_top_card)
      end
    end
  end
end
