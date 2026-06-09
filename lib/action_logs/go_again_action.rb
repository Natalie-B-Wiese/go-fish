require_relative 'action'

class GoAgainAction < Action
  def initialize(current_player)
    super(current_player, nil)
  end

  def to_s(player)
    "#{player_to_s(player)} can go again!"
  end
end
