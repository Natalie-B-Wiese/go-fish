require_relative 'action'

class RequestAction < Action
  attr_reader :rank

  def initialize(current_player, opponent_player, rank)
    super(current_player, opponent_player)
    @rank = rank
  end

  def to_s(player)
    "#{player_to_s(player)} requested a #{rank} from #{opponent_to_s(player, false)}."
  end
end
