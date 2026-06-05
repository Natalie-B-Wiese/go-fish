require 'socket'
require_relative '../lib/socket_server'
require_relative 'mock_socket_client'

describe SocketServer do
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

  it 'is not listening on a port before it is started' do
    @server.stop
    expect { MockSocketClient.new(SocketServer::PORT) }.to raise_error(Errno::ECONNREFUSED)
  end

  describe 'when clients join' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:player1_name) { 'Jeff' }

    let(:client2) { MockSocketClient.new(SocketServer::PORT) }
    let(:player2_name) { 'Bob' }

    before do
      @clients.push client1
      @server.accept_new_client(player1_name)
    end

    it 'new clients get a welcome message' do
      expect(client1.capture_output).to match(/welcome/i)
    end

    it 'other clients are notified about new player' do
      client1.capture_output

      @clients.push client2
      @server.accept_new_client(player2_name)
      client2.capture_output

      expect(client1.capture_output.chomp).to eq "#{player2_name} joined the game!"
    end

    it 'new client sees list of other players' do
      @clients.push client2
      @server.accept_new_client(player2_name)

      expect(client2.capture_output.chomp).to match(/#{player1_name}/)
    end
  end

  describe 'pending clients' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:player1_name) { 'Jeff' }

    let(:client2) { MockSocketClient.new(SocketServer::PORT) }
    let(:player2_name) { 'Bob' }

    before do
      @clients.push client1
      @server.accept_new_client(player1_name)

      @clients.push client2
      @server.accept_new_client(player2_name)
    end

    it 'get ready prompt' do
      @server.create_game_if_possible
      expect(client1.capture_output).to match(/ready/i)
      expect(client2.capture_output).to match(/ready/i)
    end

    it 'ready prompt happens only once' do
      @server.create_game_if_possible
      client1.capture_output
      client2.capture_output

      @server.create_game_if_possible
      expect(client1.capture_output).to be_empty
      expect(client2.capture_output).to be_empty
    end

    context 'when all players confirmed' do
      it 'shows starting message to all players' do
        client1.capture_output
        client2.capture_output

        client1.provide_input('I am sooooo ready')
        client2.provide_input('\n')

        @server.create_game_if_possible

        expect(client1.capture_output).to match(/starting/i)
        expect(client2.capture_output).to match(/starting/i)
      end
    end
  end

  describe '#create_game_if_possible' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:player1_name) { 'Jeff' }

    before do
      @clients.push client1
      @server.accept_new_client(player1_name)
    end

    context '1 ready player' do
      it 'does not create a game' do
        client1.provide_input('I am sooooo ready')

        @server.create_game_if_possible
        expect(@server.games.count).to be 0
      end
    end

    context '2+ players' do
      let(:client2) { MockSocketClient.new(SocketServer::PORT) }
      let(:player2_name) { 'Bob' }

      before do
        @clients.push client2
        @server.accept_new_client(player2_name)
      end

      context '0 ready' do
        it 'does not create a game' do
          @server.create_game_if_possible
          expect(@server.games.count).to be 0
        end
      end

      context '1 ready' do
        it 'does not create a game' do
          client1.provide_input('I am sooooo ready')
          @server.create_game_if_possible
          expect(@server.games.count).to be 0
        end
      end

      context 'all ready' do
        it 'creates a game' do
          client1.provide_input('I am sooooo ready')
          client2.provide_input('Ready')

          @server.create_game_if_possible
          expect(@server.games.count).to eq 1
        end
      end
    end
  end
end
