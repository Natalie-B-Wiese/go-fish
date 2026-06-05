require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/deck'
require_relative '../lib/card'

describe Game do
  # creates a deck
  # deals the deck between the two players
  # the deck should be shuffled
  describe '#initialize' do
    let(:player1) { Player.new('Jeff') }
    let(:player2) { Player.new('Bob') }
    let(:players) { [player1, player2] }

    let(:game) { described_class.new(players) }

    it 'contains an array of players' do
      expect(game.players).to eq players
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
    let(:player1) { Player.new('Jeff') }
    let(:player2) { Player.new('Bob') }
    let(:player3) { Player.new('Billy') }
    let(:player4) { Player.new('Batman') }

    # shuffles a deck
    # deals the deck to the players

    context 'with 2 or 3 players' do
      let(:players) { [player1, player2] }
      let(:game) { described_class.new(players) }

      let(:cards_per_player) { 7 }
      let(:card_indices_used) { (0...(cards_per_player * players.length)).to_a }

      before do
        game.start
      end

      it 'deals 7 cards to each player' do
        expect(player1.cards.length).to eq cards_per_player
        expect(player2.cards.length).to eq cards_per_player
      end

      # this assumes that it alternates between players when dealing the cards
      it 'cards are shuffled' do
        # even numbers (on 2 players)
        p1_unshuffled_card_indices = card_indices_used.select { |x| x % players.length == 0 }

        # odd numbers (for 2 players)
        p2_unshuffled_card_indices = card_indices_used.select { |x| (x + 1) % players.length == 0 }

        p1_unshuffled = p1_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p2_unshuffled = p2_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }

        expect(player1.cards).to_not eq p1_unshuffled
        expect(player2.cards).to_not eq p2_unshuffled
      end
    end

    context 'with 4 or more players' do
      let(:players) { [player1, player2, player3, player4] }
      let(:game) { described_class.new(players) }

      let(:cards_per_player) { 5 }
      let(:card_indices_used) { (0...(cards_per_player * players.length)).to_a }

      before do
        game.start
      end

      it 'deals 5 cards to each player' do
        expect(player1.cards.length).to eq cards_per_player
        expect(player2.cards.length).to eq cards_per_player
        expect(player3.cards.length).to eq cards_per_player
        expect(player4.cards.length).to eq cards_per_player
      end

      # this assumes the deal method alternates between players when dealing
      it 'cards are shuffled' do
        # [0, 4, 8, 12, 16]
        p1_unshuffled_card_indices = card_indices_used.select { |x| x % players.length == 0 }

        # [1, 5, 9, 13, 17]
        p2_unshuffled_card_indices = card_indices_used.select { |x| (x + 1) % players.length == 0 }

        # [2, 6, 10, 14, 18]
        p3_unshuffled_card_indices = card_indices_used.select { |x| (x + 2) % players.length == 0 }

        # [3, 7, 11, 15, 19]
        p4_unshuffled_card_indices = card_indices_used.select { |x| (x + 2) % players.length == 0 }

        p1_unshuffled = p1_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p2_unshuffled = p2_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p3_unshuffled = p3_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }
        p4_unshuffled = p4_unshuffled_card_indices.map { |index| unshuffled_deck.cards[index] }

        expect(player1.cards).to_not eq p1_unshuffled
        expect(player2.cards).to_not eq p2_unshuffled
        expect(player3.cards).to_not eq p3_unshuffled
        expect(player4.cards).to_not eq p4_unshuffled
      end
    end
  end

  describe '#request_deck_card' do
    let(:player1) { Player.new('Jeff') }
    let(:player2) { Player.new('Bob') }
    let(:players) { [player1, player2] }

    let(:game) { described_class.new(players) }

    let(:ace_spades) { Card.new('A', 'Spades') }
    let(:ace_clubs)  { Card.new('A', 'Clubs') }
    let(:ace_hearts) { Card.new('A', 'Hearts') }

    let(:ace_diamonds) { Card.new('A', 'Diamonds') }
    let(:other_card) { Card.new('5', 'Spades') }

    let(:player1_index) { 0 }
    let(:player2_index) { 1 }

    context 'when deck is empty' do
      before do
        game.deck.cards = []
      end

      it 'switches turn' do
        game.request_deck_card('A')
        expect(game.current_player_index).to eq player2_index
      end
    end

    context 'when player does not get correct card from deck' do
      before do
        player1.add_cards([ace_spades, ace_clubs, ace_hearts])
        game.deck.cards = [other_card, ace_diamonds]
      end

      it 'switches turn' do
        game.request_deck_card('A')
        expect(game.current_player_index).to eq player2_index
      end
    end

    xcontext 'when player has cards and deck has cards' do
      before do
        player1.add_cards([ace_spades, ace_clubs, ace_hearts])
        game.deck.cards = [ace_diamonds, other_card]
      end

      it 'removes the card from the deck' do
        card_count_before = game.deck.cards.length
        game.request_deck_card('A')
        expect(game.deck.cards.length).to eq(card_count_before - 1)
      end

      it 'adds the card to the player' do
        card_count_before = player1.cards.length
        game.request_deck_card('A')
        expect(player1.cards.length).to eq(card_count_before + 1)
      end

      context 'when player gets correct card from deck' do
        it 'makes player have another turn' do
          player1_index = 0

          game.request_deck_card('A')
          expect(game.current_player_index).to eq player1_index
        end
      end
    end

    xcontext 'when player does not have cards' do
      context 'when there are cards in the deck' do
      end

      context 'when the deck is empty' do
        # player is out of the game
      end
    end
  end

  xdescribe '#play_round' do
    let(:player1) { Player.new('Jeff') }
    let(:player2) { Player.new('Bob') }
    let(:players) { [player1, player2] }

    let(:game) { described_class.new(players) }

    before do
      # forcefully set the hands
      ace_spades = Card.new('A', 'Spades')
      ace_clubs = Card.new('A', 'Clubs')
      ace_hearts = Card.new('A', 'Hearts')
      ace_diamonds = Card.new('A', 'Diamonds')

      jack_spades = Card.new('Jack', 'Spades')
      jack_clubs = Card.new('Jack', 'Clubs')
      jack_hearts = Card.new('Jack', 'Hearts')

      jack_diamonds = Card.new('Jack', 'Diamonds')

      other_card = Card.new('5', 'Spades')

      player1.add_cards([ace_spades, ace_clubs, ace_hearts, jack_spades])
      player2.add_cards([jack_clubs, jack_hearts, ace_diamonds])

      game.deck.cards = [other_card, jack_diamonds]
    end

    context 'when player has cards' do
      context 'when player gets correct card from opponent' do
        it 'gives player the card from opponent' do
          game.play_round

          # how to make request of player 1 for
        end

        it 'allows player to go again' do
        end
      end

      context 'when player goes fish and gets correct card from deck' do
      end

      context 'when player goes fish and deck is empty' do
      end

      context 'when player gets correct card and can make a book' do
      end
    end

    context 'when player does not have cards' do
      context 'when there are cards in the deck' do
      end

      context 'when the deck is empty' do
        # player is out of the game
      end
    end
  end
end
