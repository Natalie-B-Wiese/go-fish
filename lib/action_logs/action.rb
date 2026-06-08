class Action
  attr_reader :current_player, :opponent_player

  def initialize(current_player, opponent_player)
    @current_player = current_player
    @opponent_player = opponent_player

    return unless self.class == Action

    raise 'Cannot directly instantiate TurnResult. Please use a subclass.'
  end

  def to_s(player)
    raise 'Override to_s(player)!'
  end

  def opponent_to_s(you_player)
    player_variable_to_s(opponent_player, you_player)
  end

  def player_to_s(you_player)
    player_variable_to_s(current_player, you_player)
  end

  private

  def player_variable_to_s(variable_player, you_player)
    variable_player == you_player ? 'You' : variable_player.name
  end
end
