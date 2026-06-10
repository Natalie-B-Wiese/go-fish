class Action
  attr_reader :current_player, :opponent_player, :rank_requested, :cards_received, :was_book_made

  def initialize(current_player:, opponent_player: nil, rank_requested: nil,
                 cards_received: [], was_book_made: false)
    @current_player = current_player
    @opponent_player = opponent_player
    @rank_requested = rank_requested
    @cards_received = cards_received
    @was_book_made = was_book_made
  end

  def message(player)
    if book_made?
      book_message(player)
    else
      puts 'other'
    end
  end

  private

  def book_message(player)
    "#{player_to_s(player)} made a book"
  end

  def deck_empty?
    !book_made? && cards_received.nil?
  end

  def book_made?
    !!was_book_made
  end

  def went_fish?
    opponent_player.nil?
  end

  def opponent_to_s(you_player, is_subject = true)
    player_variable_to_s(opponent_player, you_player, is_subject)
  end

  def player_to_s(you_player, is_subject = true)
    player_variable_to_s(current_player, you_player, is_subject)
  end

  def player_variable_to_s(variable_player, you_player, is_subject)
    you = 'You'
    you = you.downcase unless is_subject
    variable_player == you_player ? you : variable_player.name
  end
end
