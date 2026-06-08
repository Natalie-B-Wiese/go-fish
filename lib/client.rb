require 'socket'
require_relative 'player'
require_relative 'client_message'

class Client
  INPUT_SYMBOL = '->'

  attr_reader :socket, :player, :messages

  def initialize(socket, name)
    @socket = socket
    @player = Player.new(name)

    @messages = {
      ready: ClientMessage.new,
      rank: ClientMessage.new,
      opponent: ClientMessage.new
    }
  end

  def name
    player.name
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
    # TODO: add a guard clause if both rank and opponent are not nil

    choose_rank unless messages[:rank].value?

    return unless messages[:rank].value?

    choose_opponent(game)
    return unless messages[:opponent].value?

    puts 'Everything is valid!'
  end

  def read_socket
    socket.read_nonblock(1000)
  rescue IO::WaitReadable
    ''
  end

  private

  def valid_rank?
    player.includes_card_with_rank?(messages[:rank].value)
  end

  def valid_opponent?(game)
    # TODO: implement this method so it is a valid opponent
    # Opponent is valid if it is a player that is not self
    true
  end

  def choose_rank
    return if messages[:rank].value?

    ask('Enter rank') unless messages[:rank].sent?
    messages[:rank].send
    messages[:rank].value = read_socket.chomp

    return if !messages[:rank].value? || valid_rank?

    messages[:rank].reset
    puts 'Invalid rank!'
  end

  def choose_opponent(game)
    return if messages[:opponent].value?

    unless messages[:opponent].sent?
      puts game.all_but_current_client.map(&:name).join(', ')
      ask('Enter player')
    end

    messages[:opponent].send
    messages[:opponent].value = read_socket.chomp

    return if !messages[:opponent].value? || valid_opponent?(game)

    messages[:opponent].reset
    puts 'Invalid player!'
  end
end
