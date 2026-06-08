require 'socket'
require_relative '../lib/client_message'
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
    expect { MockSocketClient.new(SocketServer::PORT, 'Player 1') }.to raise_error(Errno::ECONNREFUSED)
  end

  describe 'when clients join' do
    let(:player1_name) { 'Jeff' }
    let(:client1) { MockSocketClient.new(SocketServer::PORT, player1_name) }

    let(:player2_name) { 'Bob' }
    let(:client2) { MockSocketClient.new(SocketServer::PORT, player2_name) }

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
    let(:player1_name) { 'Jeff' }
    let(:client1) { MockSocketClient.new(SocketServer::PORT, player1_name) }

    let(:player2_name) { 'Bob' }
    let(:client2) { MockSocketClient.new(SocketServer::PORT, player2_name) }

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
    let(:player1_name) { 'Jeff' }
    let(:client1) { MockSocketClient.new(SocketServer::PORT, player1_name) }

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
      let(:player2_name) { 'Bob' }
      let(:client2) { MockSocketClient.new(SocketServer::PORT, player2_name) }

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

  describe '#play_turn' do
    let(:player1_name) { 'Jeff' }
    let(:client1) { MockSocketClient.new(SocketServer::PORT, player1_name) }

    let(:player2_name) { 'Henry' }
    let(:client2) { MockSocketClient.new(SocketServer::PORT, player2_name) }

    let(:player3_name) { 'Billy' }
    let(:client3) { MockSocketClient.new(SocketServer::PORT, player3_name) }

    before do
      @clients.push client1
      @server.accept_new_client(player1_name)
      @clients.push client2
      @server.accept_new_client(player2_name)
      @clients.push client3
      @server.accept_new_client(player3_name)

      client1.provide_input('I am sooooo ready')
      client2.provide_input('Ready')
      client3.provide_input('Ready')

      @server.create_game_if_possible
      game = @server.games[0]
      game.start

      client1.capture_output
      client2.capture_output
      client3.capture_output

      game.play_turn
    end

    context 'for all players' do
      let(:client1_ranks) { @server.clients[0].player.cards.map(&:rank).join(' ') }
      let(:client2_ranks) { @server.clients[1].player.cards.map(&:rank).join(' ') }
      let(:client3_ranks) { @server.clients[2].player.cards.map(&:rank).join(' ') }

      it 'shows their card ranks' do
        result1 = client1.capture_output
        expect(result1).to match(/#{client1_ranks}/)

        result2 = client2.capture_output
        expect(result2).to match(/#{client2_ranks}/)

        result3 = client3.capture_output
        expect(result3).to match(/#{client3_ranks}/)
      end

      it 'shows turn info only once' do
        client1.capture_output
        client2.capture_output
        client3.capture_output

        @server.games[0].play_turn

        expect(client1.capture_output).to_not match(/turn/)
        expect(client2.capture_output).to_not match(/turn/)
        expect(client3.capture_output).to_not match(/turn/)
      end

      it 'shows cards only once' do
        client1.capture_output
        client2.capture_output
        client3.capture_output

        @server.games[0].play_turn

        expect(client1.capture_output).to_not match(/#{client1_ranks}/)
        expect(client2.capture_output).to_not match(/#{client2_ranks}/)
        expect(client3.capture_output).to_not match(/#{client3_ranks}/)
      end
    end

    context 'on current player' do
      it 'prints It is your turn' do
        result = client1.capture_output
        expect(result).to match(/It is your turn/i)
      end

      it 'does not print It is player_name\'s turn' do
        result = client1.capture_output
        expect(result).to_not match(/It is #{player1_name}'s turn/)
      end

      it 'asks for rank' do
        result = client1.capture_output
        expect(result).to match(/Enter rank/i)
      end

      context 'invalid rank entered' do
        before do
          client1.capture_output
          invalid_rank = 'banana'
          client1.provide_input(invalid_rank)

          @server.games[0].play_turn
        end

        it 'prints invalid rank' do
          result = client1.capture_output
          expect(result).to match(/Invalid rank/i)
        end

        it 'does not show list of players' do
          result = client1.capture_output
          expect(result).to_not match(/#{player2_name}, #{player3_name}/)
        end
      end

      context 'after getting valid rank' do
        before do
          client1.capture_output
          valid_rank = @server.clients[0].player.cards[0].rank
          client1.provide_input(valid_rank)

          @server.games[0].play_turn
        end

        it 'shows list of players excluding self' do
          result = client1.capture_output
          expect(result).to match(/#{player2_name}, #{player3_name}/)
        end

        it 'asks for player' do
          result = client1.capture_output
          expect(result).to match(/Enter player/i)
        end

        context 'when invalid player' do
          before do
            invalid_name = player1_name
            client1.provide_input(invalid_name)
            @server.games[0].play_turn
          end

          it 'prints invalid player' do
            result = client1.capture_output
            expect(result).to match(/Invalid player/i)
          end
        end

        context 'when valid player' do
          before do
            valid_name = player2_name
            client1.provide_input(valid_name)
            @server.games[0].play_turn
          end

          it 'prints round result to all players' do
            expect(client1.capture_output).to match(/Round result: You asked #{player2_name}/i)
            expect(client2.capture_output).to match(/Round result: #{player1_name} asked you/i)
            expect(client3.capture_output).to match(/Round result: #{player1_name} asked #{player2_name}/i)
          end
        end
      end
    end

    # it prints the player's turn to all players
    context 'for other players' do
      it "prints it is player_name's turn" do
        result1 = client2.capture_output
        expect(result1).to match(/It is #{player1_name}'s turn/)

        result2 = client3.capture_output
        expect(result2).to match(/It is #{player1_name}'s turn/)
      end
    end

    # this rank is validated to belong to the player
    # once validated, it asks the player to choose who to ask it from
    # This name must be validated to be a player and to not be self
    # Once everything is validated, the request is made
    # All clients receive a puts about this request (Turn_Info)
  end
end
