require 'socket'
require_relative 'player'
require_relative 'client_message'

class Client
  INPUT_SYMBOL = '->'

  attr_reader :socket, :player
  attr_accessor :is_input_valid, :has_shown_round, :messages

  def initialize(socket, name)
    @socket = socket
    @player = Player.new(name)
    @is_input_valid = false
    @has_shown_round = false

    @messages = {
      ready: ClientMessage.new,
      rank: ClientMessage.new,
      opponent: ClientMessage.new
    }
  end

  def reset_variables
    self.is_input_valid = false
    self.has_shown_round = false

    self.messages = {
      ready: ClientMessage.new,
      rank: ClientMessage.new,
      opponent: ClientMessage.new
    }
  end

  def name
    player.name
  end

  def input_valid?
    !!is_input_valid
  end

  def ready?
    messages[:ready].true?
  end

  def puts(message)
    socket.puts(message)
  end

  def ask(message)
    socket.puts(message + INPUT_SYMBOL)
  end

  def check_ready!
    return if ready?

    ask('Press ENTER when you are ready') unless messages[:ready].sent?
    messages[:ready].send
    messages[:ready].value = !read_socket.empty?
  end

  # returns a valid rank and player
  def valid_rank_and_player(game)
    return if input_valid?

    choose_rank unless messages[:rank].value?
    return unless messages[:rank].value?

    choose_opponent(game)
    return unless messages[:opponent].value?

    self.is_input_valid = true
  end

  def read_socket
    socket.read_nonblock(1000)
  rescue IO::WaitReadable
    ''
  end

  def try_print_round(current_client)
    return if shown_round?

    print_round(current_client.player)
  end

  private

  def shown_round?
    !!has_shown_round
  end

  def print_round(current_player)
    puts(player.cards_to_s)
    print_turn(current_player)
    self.has_shown_round = true
  end

  def print_turn(current_player)
    if current_player == player
      puts('It is your turn')
    else
      puts("It is #{current_player.name}'s turn")
    end
  end

  def valid_rank?
    player.includes_card_with_rank?(messages[:rank].value)
  end

  def valid_opponent?(game)
    # Opponent is valid if it is a player that is not self
    game.all_but_current_player_names.include?(messages[:opponent].value)
  end

  def choose_rank
    return if valid_rank?

    ask('Enter rank') unless messages[:rank].sent?
    messages[:rank].send
    input = read_socket

    return if input.empty?

    messages[:rank].value = input.chomp
    return if valid_rank?

    messages[:rank].reset
    puts 'Invalid rank!'
  end

  def choose_opponent(game)
    return if valid_opponent?(game)

    unless messages[:opponent].sent?
      puts game.all_but_current_player_names.join(', ')
      ask('Enter player')
    end

    messages[:opponent].send
    input = read_socket
    return if input.empty?

    messages[:opponent].value = input.chomp
    return if valid_opponent?(game)

    messages[:opponent].reset
    puts 'Invalid player!'
  end
end
