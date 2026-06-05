require 'socket'
require_relative '../lib/socket_server'

require_relative '../lib/client'

require_relative '../lib/game'
require_relative 'mock_socket_client'
require_relative 'mock_socket'

# initialize(socket, name)
# Sets @socket to socket
# sets @name to name
# initializes is_ready and is_message_sent to false
describe Client do
  before(:each) do
    @clients = []
    @server = SocketServer.new
    @server.start
    sleep 0.1 # Ensure server is ready for clients
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end

  describe '#initialize' do
    let(:socket) { MockSocket.new }
    let(:client) { Client.new(socket, 'Player 1') }

    it 'sets socket correctly' do
      expect(client.socket).to eq socket
    end
    it 'sets name correctly' do
      expect(client.name).to eq 'Player 1'
    end
  end
end
