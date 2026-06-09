require_relative 'deck'
require_relative 'action_logs/action'
require_relative 'action_logs/request_action'
require_relative 'action_logs/give_action'
require_relative 'action_log'

class Game
  attr_reader :clients, :deck
  attr_accessor :current_player_index, :action_log

  MIN_PLAYERS = 2

  # validate input method.
  # Socket should call it before calling any other game methods (go_fish, request_player_card)
  # That way they don't show errors

  # game collaborates with server
  # Player does not collaborate with server

  def initialize(client_objs)
    @clients = client_objs
    @deck = Deck.new
    @current_player_index = 0
    @action_log = ActionLog.new
  end

  def players
    clients.map(&:player)
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
  def play_turn
    print_round
    current_client.valid_rank_and_player(self)

    return unless current_client.input_valid?

    opponent_name = current_client.messages[:opponent].value
    rank = current_client.messages[:rank].value

    current_client.reset_variables

    create_request_action(opponent_name, rank)
    request_card_from_player(rank, opponent_name)
  end

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

  def current_client
    clients[current_player_index]
  end

  def current_player
    players[current_player_index]
  end

  # used by player
  def all_but_current_client
    clients - [current_client]
  end

  def all_but_current_player_names
    all_but_current_client.map(&:name)
  end

  private

  def create_request_action(opponent_name, rank)
    action = RequestAction.new(current_player,
                               find_player_by_name(opponent_name),
                               rank)
    action_log.push(action)

    print_log_result
  end

  def print_log_result
    clients.each do |client|
      client.puts(action_log.most_recent.to_s(client.player))
    end
  end

  def print_round
    clients.each do |client|
      client.try_print_round(current_client)
    end
  end

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
