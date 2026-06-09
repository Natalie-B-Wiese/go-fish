require_relative 'action'

class DeckAction < Action
  attr_reader :rank, :rank_taken

  def initialize(current_player, rank, rank_taken = nil)
    super(current_player, nil)
    @rank = rank
    @rank_taken = rank_taken
  end

  def to_s(player)
    if deck_empty?
      'Deck is empty!'
    elsif successful?
      "#{player_to_s(player)} successfully got a #{rank_taken} from the deck"
    else
      unsuccessful_message(player)
    end
  end

  private

  def unsuccessful_message(player)
    if player == current_player
      "You got a #{rank_taken} from the deck"
    else
      "#{player_to_s(player)} got a card from the deck"
    end
  end

  def deck_empty?
    rank_taken.nil?
  end

  def successful?
    rank == rank_taken
  end
end
