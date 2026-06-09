require_relative 'action'

class BookAction < Action
  attr_reader :rank

  def initialize(current_player, rank)
    super(current_player, nil)
    @rank = rank
  end

  def to_s(player)
    "#{player_to_s(player)} made a book with #{rank}"
  end
end
