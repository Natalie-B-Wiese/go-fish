require_relative 'socket_server'

server = SocketServer.new
server.start
while true
  begin
    server.accept_new_client
    game = server.create_game_if_possible
    if game
      server.run_game(game)

      # for testing purposes, only runs the game once
      return
    end
  rescue StandardError
    server.stop
  end

end
