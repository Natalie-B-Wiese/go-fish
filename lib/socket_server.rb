require 'socket'
require 'client'

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

  private

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

  # Wait and accept a single incoming connection
  # client = server.accept

  # Send a greeting to the client
  # client.puts 'Hello from the Ruby TCP Server!'

  # Clean up connections
  # client.close
  # server.close
end
