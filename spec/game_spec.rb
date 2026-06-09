require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/deck'
require_relative '../lib/card'
require_relative '../lib/client'

describe Game do
  before do
    allow_any_instance_of(Client).to receive(:puts)
  end

  # creates a deck
  # deals the deck between the two players
  # the deck should be shuffled
  describe '#initialize' do
    let(:client1) { Client.new('socket', 'Jeff') }
    let(:client2) { Client.new('socket', 'Bob') }
    let(:clients) { [client1, client2] }

    let(:game) { described_class.new(clients) }

    it 'contains an array of clients' do
      expect(game.clients).to eq clients
    end

    it 'creates a deck of cards' do
      expect(game.deck).to be_a(Deck)
    end

    it 'sets current_player_index to 0' do
      expect(game.current_player_index).to eq 0
    end
  end

  describe '#start' do
    let(:unshuffled_deck) { Deck.new }
    let(:client1) { Client.new('socket', 'Jeff') }
    let(:client2) { Client.new('socket', 'Bob') }
    let(:client3) { Client.new('socket', 'Billy') }
    let(:client4) { Client.new('socket', 'Batman') }

    # shuffles a deck
    # deals the deck to the players

    context 'with 2 or 3 players' do
      let(:clients) { [client1, client2] }
      let(:game) { described_class.new(clients) }

      let(:cards_per_player) { 7 }
      let(:card_indices_used) { (0...(cards_per_player * clients.length)).to_a }

      before do
        game.start
      end

      it 'deals 7 cards to each player' do
        expect(client1.player.cards.length).to eq cards_per_player
        expect(client2.player.cards.length).to eq cards_per_player
      end

      # this assumes that it alternates between players when dealing the cards
      it 'cards are shuffled' do
        # even numbers (on 2 players)
        p1_unshuffled_card_indices = card_indices_used.select { |x| x % clients.length == 0 }

        # odd numbers (for 2 players)
        p2_unshuffled_card_indices = card_indices_used.select { |x| (x + 1) % clients.length == 0 }

        p1_unshuffled = p1_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p2_unshuffled = p2_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }

        expect(client1.player.cards).to_not eq p1_unshuffled
        expect(client2.player.cards).to_not eq p2_unshuffled
      end
    end

    context 'with 4 or more players' do
      let(:clients) { [client1, client2, client3, client4] }
      let(:game) { described_class.new(clients) }

      let(:cards_per_player) { 5 }
      let(:card_indices_used) { (0...(cards_per_player * clients.length)).to_a }

      before do
        game.start
      end

      it 'deals 5 cards to each player' do
        expect(client1.player.cards.length).to eq cards_per_player
        expect(client2.player.cards.length).to eq cards_per_player
        expect(client3.player.cards.length).to eq cards_per_player
        expect(client4.player.cards.length).to eq cards_per_player
      end

      # this assumes the deal method alternates between players when dealing
      it 'cards are shuffled' do
        # [0, 4, 8, 12, 16]
        p1_unshuffled_card_indices = card_indices_used.select { |x| x % clients.length == 0 }

        # [1, 5, 9, 13, 17]
        p2_unshuffled_card_indices = card_indices_used.select { |x| (x + 1) % clients.length == 0 }

        # [2, 6, 10, 14, 18]
        p3_unshuffled_card_indices = card_indices_used.select { |x| (x + 2) % clients.length == 0 }

        # [3, 7, 11, 15, 19]
        p4_unshuffled_card_indices = card_indices_used.select { |x| (x + 2) % clients.length == 0 }

        p1_unshuffled = p1_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p2_unshuffled = p2_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p3_unshuffled = p3_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p4_unshuffled = p4_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }

        expect(client1.player.cards).to_not eq p1_unshuffled
        expect(client2.player.cards).to_not eq p2_unshuffled
        expect(client3.player.cards).to_not eq p3_unshuffled
        expect(client4.player.cards).to_not eq p4_unshuffled
      end
    end
  end

  describe '#request_deck_card' do
    let(:client1) { Client.new('socket', 'Jeff') }
    let(:client2) { Client.new('socket', 'Bob') }
    let(:clients) { [client1, client2] }

    let(:game) { described_class.new(clients) }

    let(:ace_spades) { Card.new('A', 'Spades') }
    let(:ace_clubs)  { Card.new('A', 'Clubs') }

    let(:ace_diamonds) { Card.new('A', 'Diamonds') }
    let(:other_card) { Card.new('5', 'Spades') }

    let(:player1_index) { 0 }
    let(:player2_index) { 1 }

    context 'deck is empty' do
      before do
        game.deck.cards = []
      end

      it 'switches turn' do
        game.request_deck_card('A')
        expect(game.current_player_index).to eq player2_index
      end
    end

    context 'does not get requested card' do
      before do
        client1.player.add_cards([ace_spades, ace_clubs])
        game.deck.cards = [other_card, ace_diamonds]
      end

      it 'removes the card from the top of the deck' do
        game.request_deck_card('A')
        expect(game.deck.cards).to_not include other_card
      end

      it 'gives the card to the player' do
        game.request_deck_card('A')
        expect(client1.player.cards).to include other_card
      end

      it 'switches turn' do
        game.request_deck_card('A')
        expect(game.current_player_index).to eq player2_index
      end
    end

    context 'gets correct card' do
      before do
        client1.player.add_cards([ace_spades, ace_clubs])
        game.deck.cards = [ace_diamonds, other_card]
      end

      it 'removes the card from the top of the deck' do
        game.request_deck_card('A')
        expect(game.deck.cards).to_not include ace_diamonds
      end

      it 'gives the card to the player' do
        game.request_deck_card('A')
        expect(client1.player.cards).to include ace_diamonds
      end

      it 'does not switch turn' do
        game.request_deck_card('A')
        expect(game.current_player_index).to eq player1_index
      end
    end
  end

  describe '#request_card_from_player' do
    let(:client) { Client.new('socket', 'Jeff') }
    let(:opponent) { Client.new('socket', 'Bob') }
    let(:clients) { [client, opponent] }

    let(:game) { described_class.new(clients) }

    let(:request_rank) { 'A' }
    let(:incorrect_rank) { '5' }
    let(:good_card) { Card.new(request_rank, 'Clubs') }
    let(:other_card) { Card.new(incorrect_rank, 'Spades') }

    before do
      client.player.add_card(Card.new(request_rank, 'Spades'))
    end

    context 'opponent not have card' do
      before do
        opponent.player.add_card(other_card)
      end

      it 'does not remove opponent card' do
        game.request_card_from_player(request_rank, opponent.name)
        expect(opponent.player.cards).to include other_card
      end

      context 'goes fish' do
        context 'gets requested card' do
          before do
            game.deck.cards = [good_card]
          end

          it 'does not switch turn' do
            game.request_card_from_player(request_rank, opponent.name)
            expect(game.current_client).to eq client
          end
        end

        context 'not get card' do
          before do
            game.deck.cards = [Card.new(incorrect_rank, 'Clubs')]
          end

          it 'switches turn' do
            game.request_card_from_player(request_rank, opponent.name)
            expect(game.current_client).to eq opponent
          end
        end
      end
    end

    context 'gets correct card' do
      before do
        opponent.player.add_cards([other_card, good_card])
      end

      it 'removes the card from opponent' do
        game.request_card_from_player(request_rank, opponent.name)
        expect(opponent.player.cards).to_not include good_card
      end

      it 'gives the card to the player' do
        game.request_card_from_player(request_rank, opponent.name)
        expect(client.player.cards).to include good_card
      end

      it 'does not switch turn' do
        game.request_card_from_player(request_rank, opponent.name)
        expect(game.current_client).to eq client
      end

      it 'works with multiple matching cards' do
        player_cards_before = client.player.cards.length
        opponent.player.add_card(Card.new(request_rank, 'Diamonds'))
        opponent_cards_before = opponent.player.cards.length
        matching_card_count = 2

        game.request_card_from_player(request_rank, opponent.name)

        expect(client.player.cards.length).to eq(player_cards_before + matching_card_count)
        expect(opponent.player.cards.length).to eq(opponent_cards_before - matching_card_count)
      end
    end
  end

  describe '#winning_player' do
    let(:client1) { Client.new('socket', 'Jeff') }
    let(:client2) { Client.new('socket', 'Bob') }
    let(:client3) { Client.new('socket', 'Billy') }
    let(:clients) { [client1, client2, client3] }

    let(:game) { described_class.new(clients) }

    context 'when one player has most books' do
      before do
        client1.player.books = []
        client2.player.books = [Book.new(5), Book.new(2), Book.new(10)]
        client3.player.books = [Book.new(12)]
      end

      it 'returns that player' do
        result = game.winning_player

        expect(result).to eq client2.player
      end
    end

    context 'when there is a tie' do
      before do
        client1.player.books = [Book.new(8), Book.new(5), Book.new(2)]
        client2.player.books = [Book.new(5), Book.new(3), Book.new(4)]
        client3.player.books = [Book.new(15)]
      end

      it 'returns player with most book and highest value book' do
        result = game.winning_player
        expect(result).to eq client1.player
      end
    end
  end
end
