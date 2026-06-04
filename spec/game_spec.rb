require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/deck'

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
  end
end
