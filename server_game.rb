class ServerGame
  attr_reader :clients, :game

  def initialize(clients, game_type = WarGame)
    @clients = clients
    @game = game_type.new
  end

  # prints the winner to all players
  def game_over
    @clients.each do |client|
      client.puts("Winner: #{winner.name}")
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

  # Should this jsut be part of the initailize method of this server game?
  def start
    game.start
  end

  def try_play_round
    if clients_ready?
      puts_to_clients(clients, 'Both players are ready!')
      play_round
    else
      ready_clients.each do |client|
        client.try_send_waiting_for_player_message
      end
    end
  end

  def puts_to_clients(clients_array, message)
    clients_array.each { |client| client.puts message }
  end

  def winner
    game.winner
  end

  def play_round
    round_result = game.play_round

    clients.each do |client|
      client.reset_variables
      client.puts(round_result)
    end

    # sends message to server
    puts progress
  end

  def progress
    game.progress
  end
end
