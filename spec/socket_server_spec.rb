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

  context 'when clients join' do
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

  xit 'all players get a starting message when the second client joins' do
    client1 = MockSocketClient.new(SocketServer::PORT)
    @clients.push(client1)
    @server.accept_new_client('Player 1')
    client1.capture_output

    client2 = MockSocketClient.new(SocketServer::PORT)
    @clients.push(client2)
    @server.accept_new_client('Player 2')

    @server.create_game_if_possible
    expect(client1.capture_output).to match(/starting/i)
    expect(client2.capture_output).to match(/starting/i)
  end

  xit 'accepts new clients and starts a game if possible' do
    client1 = MockSocketClient.new(SocketServer::PORT)
    @clients.push(client1)
    @server.accept_new_client('Player 1')
    @server.create_game_if_possible
    expect(@server.games.count).to be 0

    client2 = MockSocketClient.new(SocketServer::PORT)
    @clients.push(client2)
    @server.accept_new_client('Player 2')
    @server.create_game_if_possible
    expect(@server.games.count).to be 1
  end

  xcontext 'if 3 clients join' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:client2) { MockSocketClient.new(SocketServer::PORT) }
    let(:client3) { MockSocketClient.new(SocketServer::PORT) }

    before do
      @clients.push client1
      @server.accept_new_client('Player 1')

      @clients.push client2
      @server.accept_new_client('Player 2')

      @server.create_game_if_possible

      @clients.push client3
      @server.accept_new_client('Player 3')

      @server.create_game_if_possible
    end

    it 'only 1 game is created' do
      expect(@server.games.count).to be 1
    end

    it 'third client does not receive starting message' do
      # expect(client3.capture_output).to match(/welcome/i)
      expect(client3.capture_output).to_not match(/starting/i)
    end
  end

  xcontext 'if 4 clients join' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:client2) { MockSocketClient.new(SocketServer::PORT) }
    let(:client3) { MockSocketClient.new(SocketServer::PORT) }
    let(:client4) { MockSocketClient.new(SocketServer::PORT) }

    before do
      @clients.push client1
      @server.accept_new_client('Player 1')

      @clients.push client2
      @server.accept_new_client('Player 2')

      @server.create_game_if_possible

      # clear the starting message
      client1.capture_output
      client2.capture_output

      @clients.push client3
      @server.accept_new_client('Player 3')

      @clients.push client4
      @server.accept_new_client('Player 4')

      @server.create_game_if_possible
    end

    it '2 games are created' do
      expect(@server.games.count).to be 2
    end

    it 'first and second client only receive one starting message' do
      expect(client3.capture_output).to_not match(/starting/i)
      expect(client4.capture_output).to_not match(/starting/i)
    end

    xit 'third and fourth client receive starting message' do
      expect(client3.capture_output).to match(/starting/i)
      expect(client4.capture_output).to match(/starting/i)
    end

    # this one causes it to freeze...
    xit 'first game contains first two clients' do
      game1 = @server.games[0]
      client1_socket = game1.clients[0].socket
      client2_socket = game1.clients[1].socket

      expect(client1_socket).to eq client1
      expect(client2_socket).to eq client2
    end

    # this one might also cause it to freeze
    xit 'second game contains second two clients' do
      game2 = @server.games[1]
      client1_socket = game2.clients[0].socket
      client2_socket = game2.clients[1].socket

      expect(client1_socket).to eq client3
      expect(client2_socket).to eq client4
    end
  end

  # Add more tests to make sure the game is being played
  # For example:
  #   make sure the mock client gets appropriate output
  #   make sure the next round isn't played until both clients say they are ready to play
  #   ...

  xdescribe '#try_play_round' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:client2) { MockSocketClient.new(SocketServer::PORT) }

    before do
      @clients.push(client1)
      @server.accept_new_client('Player 1')

      @clients.push(client2)
      @server.accept_new_client('Player 2')
      @server.create_game_if_possible

      client1.capture_output
      client2.capture_output
    end

    it 'each player gets a question that they are ready only once' do
      game = @server.games[0]
      game.start

      @server.try_play_round(game)
      expect(client1.capture_output).to match(/ready\?/i)
      expect(client2.capture_output).to match(/ready\?/i)

      @server.try_play_round(game)
      client1.capture_output
      client2.capture_output

      @server.try_play_round(game)
      expect(client1.capture_output).to be_empty
      expect(client2.capture_output).to be_empty
    end

    it 'when one player is ready, messages are correct for both players' do
      game = @server.games[0]
      game.start

      @server.try_play_round(game)
      client1.capture_output
      client2.capture_output

      client1.provide_input('I am sooooo ready')
      @server.try_play_round(game)
      expect(client1.capture_output).to match(/waiting/i)
      expect(client2.capture_output).to be_empty
    end

    context 'when all players are ready' do
      let(:game) { @server.games[0] }
      before do
        game.start

        @server.try_play_round(game)
        client1.capture_output
        client2.capture_output

        client1.provide_input('I am sooooo ready')
        @server.try_play_round(game)

        client1.capture_output
        client2.capture_output

        client2.provide_input('\n')
      end

      it 'it sends a message to both players' do
        @server.try_play_round(game)

        expect(client2.capture_output).to match(/both/i)
        expect(client1.capture_output).to match(/both/i)
      end

      it 'when all player are ready it calls play_round on game' do
        expect(game).to receive(:play_round)
        @server.try_play_round(game)
      end

      it 'it resets ready and received message variables to false' do
        @server.try_play_round(game)

        client1.capture_output
        client2.capture_output

        @server.try_play_round(game)

        expect(client1.capture_output).to match(/ready\?/i)
        expect(client2.capture_output).to match(/ready\?/i)
      end

      it 'it shows round result to server' do
        # expect($stdout).to receive(:puts).with(game.progress).at_least(1).time
        expect($stdout).to receive(:puts).at_least(1).time

        @server.try_play_round(game)
      end

      it 'it does not accept stacking input from players' do
        client1.provide_input('I am sooooo ready')
        client2.provide_input('I am sooooo ready')

        client1.provide_input('I am sooooo ready')
        client2.provide_input('I am sooooo ready')

        expect(game).to receive(:play_round).exactly(1).times

        @server.try_play_round(game)
        @server.try_play_round(game)
        @server.try_play_round(game)
      end
    end
  end

  xdescribe '#play_round' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:client2) { MockSocketClient.new(SocketServer::PORT) }

    before do
      @clients.push(client1)
      @server.accept_new_client('Player 1')

      @clients.push(client2)
      @server.accept_new_client('Player 2')
      @server.create_game_if_possible

      client1.capture_output
      client2.capture_output
    end

    it 'it shows round result to all players' do
      game = @server.games[0]
      game.start

      game.play_round

      # {winning_player.name} took a #{cards_on_table_s} with a #{winning_card}
      expect(client1.capture_output).to match(/took a/)
      expect(client2.capture_output).to match(/took a/)
    end
  end

  xdescribe '#play_game' do
    let(:client1) { MockSocketClient.new(SocketServer::PORT) }
    let(:client2) { MockSocketClient.new(SocketServer::PORT) }
    before do
      @clients.push(client1)
      @server.accept_new_client('Player 1')

      @clients.push(client2)
      @server.accept_new_client('Player 2')
      @server.create_game_if_possible

      client1.capture_output
      client2.capture_output
    end

    it 'prints the result to all players when there is a winner' do
      game = @server.games[0]
      game.start

      # force player 1 to run out of cards
      game.game.player1.instance_variable_set(:@cards, [])

      @server.play_game(game)

      expect(client1.capture_output).to match(/winner/i)
      expect(client2.capture_output).to match(/winner/i)
    end
  end
end
