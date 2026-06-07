require 'socket'
require_relative 'client'
require_relative 'game'

class SocketServer
  PORT = '3336'.freeze

  def start
    @server = TCPServer.new(PORT)
  end

  def stop
    @server.close if @server
  end

  def clients
    # if instance variable exists return it, otherwise set it to []
    @clients ||= []
  end

  def games
    @games ||= []
  end

  def accept_new_client(player_name = 'Random Player')
    client_socket = @server.accept_nonblock

    client = Client.new(client_socket, player_name)
    clients.push(client)
    client.puts "Welcome to Go Fish, #{player_name}!"
    new_client_joined
  rescue IO::WaitReadable, Errno::EINTR
    puts 'No client to accept'
  end

  def create_game_if_possible
    return if clients.length < Game::MIN_PLAYERS

    return unless clients_ready?

    puts_to_clients(clients, 'Game is starting...')

    new_game = Game.new(clients)
    games.push(new_game)
    new_game
  end

  def run_game(game)
    game.start

    # TODO: make run_round loop until there is a winner
    run_round(game)
  end

  private

  def run_round(game)
    game.play_turn
  end

  def puts_to_clients(clients_array, message)
    clients_array.each do |client|
      client.puts message
    end
  end

  def clients_ready?
    clients.each(&:check_ready!)

    clients.all?(&:ready?)
  end

  # returns the array of clients that are ready
  def ready_clients
    clients.select(&:ready?)
  end

  def new_client_joined
    all_but_newest_client.each do |client|
      # show the previously joined players the new player who joined
      client.puts "#{clients[-1].name} joined the game!"

      # show the newest player the other players in the game
      clients[-1].puts "#{client.name} joined the game!"
    end
  end

  def all_but_newest_client
    clients[0...-1]
  end
end
