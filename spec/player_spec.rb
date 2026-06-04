require_relative '../lib/player'
require_relative '../lib/card'

describe Player do
  describe '#initialize' do
    it 'has a name and empty cards' do
      player = Player.new('Natalie')

      expect(player.name).to eq 'Natalie'
      expect(player.cards).to be_empty
    end
  end

  describe '#add_card' do
    it 'adds a card to the hand' do
      player = Player.new('Natalie')
      card1 = Card.new('3', 'Diamonds')

      player.add_card(card1)
      expect(player.cards).to include(card1)
    end
  end

  describe '#add_cards' do
    it 'adds multiple cards' do
      player = Player.new('Natalie')
      card1 = Card.new('3', 'Diamonds')
      card2 = Card.new('5', 'Hearts')

      player.add_cards([card1, card2])
      expect(player.cards).to include(card1)
      expect(player.cards).to include(card2)
    end
  end

  describe '#take_cards_with_rank' do
    let(:player) { described_class.new('Natalie') }
    let(:card1) { Card.new('A', 'Diamonds') }
    let(:card2) { Card.new('2', 'Diamonds') }
    let(:card3) { Card.new('3', 'Diamonds') }

    let(:card2_same) { Card.new('2', 'Hearts') }

    before do
      player.add_cards([card1, card2, card3, card2_same])
    end

    context 'when player has one of the specified card' do
      let(:card_to_take) { card3 }
      it 'returns an array with a single card' do
        result = player.take_cards_with_rank(card_to_take.rank)
        expect(result).to eq [card_to_take]
      end

      it 'removes the card from the player' do
        player.take_cards_with_rank(card_to_take.rank)
        expect(player.cards).to_not include(card_to_take)
      end

      it 'works with non numerical cards' do
        result = player.take_cards_with_rank(card1.rank)
        expect(result).to eq [card1]
        expect(player.cards).to_not include(card1)
      end
    end

    context 'when player has more than one of the specified card' do
      it 'returns an array with all cards' do
        result = player.take_cards_with_rank('2')
        expect(result).to include(card2, card2_same)
      end

      it 'removes all the matching rank cards from the player' do
        player.take_cards_with_rank('2')
        expect(player.cards).to_not include(card2, card2_same)
      end
    end

    context 'when player does not have the specified card' do
      let(:nonexistant_rank) { 'K' }
      it 'returns nil' do
        result = player.take_cards_with_rank(nonexistant_rank)
        expect(result).to be_nil
      end

      it 'does not remove any cards from player' do
        num_cards_before = player.cards.length
        player.take_cards_with_rank(nonexistant_rank)
        expect(player.cards.length).to eq num_cards_before
      end
    end
  end

  describe '#card_count' do
    context 'when the player has no cards' do
      it 'returns 0' do
        player = Player.new('Natalie')
        result = player.card_count
        expect(result).to eq 0
      end
    end

    context 'when there is 1 card' do
      it 'returns 1' do
        player = Player.new('Natalie')
        player.add_card(Card.new('A', 'Spades'))

        result = player.card_count
        expect(result).to eq 1
      end
    end

    context 'when there are many cards' do
      it 'returns correct number' do
        player = Player.new('Natalie')
        player.add_card(Card.new('A', 'Spades'))
        player.add_card(Card.new('J', 'Diamonds'))
        player.add_card(Card.new('3', 'Hearts'))

        result = player.card_count
        expect(result).to eq 3
      end
    end
  end

  describe '#out_of_cards?' do
    let(:player) { Player.new('Natalie') }

    it 'returns true when player has no cards' do
      expect(player).to be_out_of_cards
    end

    it 'returns false when player has cards' do
      player.add_card(Card.new('A', 'Spades'))
      expect(player).to_not be_out_of_cards
    end
  end
end
