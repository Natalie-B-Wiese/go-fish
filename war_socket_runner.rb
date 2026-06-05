require_relative 'war_socket_server'

server = WarSocketServer.new
server.start
while true
  begin
    server.accept_new_client
    game = server.create_game_if_possible
    server.run_game(game) if game
  rescue StandardError
    server.stop
  end

end
