require_relative 'deck'

class Game
  attr_reader :players, :deck

  def initialize(player_objs)
    @players = player_objs
    @deck = Deck.new
  end
end
