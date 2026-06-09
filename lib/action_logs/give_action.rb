require_relative 'action'

class GiveAction < Action
  attr_reader :rank, :num_cards_taken

  def initialize(current_player, opponent_player, rank, num_cards_taken)
    super(current_player, opponent_player)
    @rank = rank
    @num_cards_taken = num_cards_taken
  end

  def to_s(player)
    if num_cards_taken.zero?
      "#{opponent_to_s(player)} did not have any #{rank}s."
    else
      "#{opponent_to_s(player)} gave #{player_to_s(player, false)} #{num_cards_taken} #{rank}s."
    end
  end
end
