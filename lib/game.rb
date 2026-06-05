require_relative 'deck'

class Game
  attr_reader :players, :deck
  attr_accessor :current_player_index

  MIN_PLAYERS = 2

  # validate input method.
  # Socket should call it before calling any other game methods (go_fish, request_player_card)
  # That way they don't show errors

  # game collaborates with server
  # Player does not collaborate with server

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

      current_player.add_card(card_taken)

      # prevent it from switching turns
      return if card_taken.rank == rank

    end

    switch_turn
  end

  # play_turn (player, rank:, opponent:)
  # play_turn (player, opponent: someone, rank: 'A')

  # rank and player_name should be validated before this is called
  def request_card_from_player(rank, player_name)
    opponent = find_player_by_name(player_name)
    cards_taken = opponent.take_cards_with_rank(rank)

    if cards_taken.empty?
      request_deck_card(rank)
    else
      current_player.add_cards(cards_taken)
    end
  end

  def current_player
    players[current_player_index]
  end

  private

  def find_player_by_name(name)
    players_with_name = players.select { |player| player.name == name }
    players_with_name[0]
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
