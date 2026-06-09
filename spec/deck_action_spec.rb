require_relative '../lib/action_logs/deck_action'
require_relative '../lib/player'

describe DeckAction do
  describe '#initialize' do
    let(:current_player) { Player.new('Jeff') }
    let(:rank) { 'A' }

    context 'with 2 parameters' do
      let(:action) { described_class.new(current_player, rank) }
      it 'sets current player' do
        expect(action.current_player).to eq current_player
      end

      it 'sets rank' do
        expect(action.rank).to eq rank
      end

      it 'sets rank_taken to nil' do
        expect(action.rank_taken).to be_nil
      end
    end

    context 'with 3 paramters' do
      let(:rank_taken) { '5' }
      let(:action) { described_class.new(current_player, rank, rank_taken) }
      it 'sets rank_taken' do
        expect(action.rank_taken).to eq rank_taken
      end
    end
  end

  describe '#to_s' do
    let(:current_player) { Player.new('Jeff') }
    let(:other_player) { Player.new('Billy') }
    let(:rank) { 'A' }

    context 'on empty deck' do
      it 'says empty deck' do
        action = DeckAction.new(current_player, rank)
        expect(action.to_s(current_player)).to match(/empty/i)
        expect(action.to_s(other_player)).to match(/empty/i)
      end
    end

    context 'on deck with cards' do
      context 'with current player' do
        let(:player_parameter) { current_player }

        context 'when unsuccessful' do
          let(:unsuccessful_rank) { '5' }

          it 'displays the card' do
            action = DeckAction.new(current_player, rank, unsuccessful_rank)
            result = action.to_s(player_parameter)
            expect(result).to eq "You got a #{unsuccessful_rank} from the deck"
          end
        end

        context 'when successful' do
          let(:successful_rank) { rank }

          it 'displays the card' do
            action = DeckAction.new(current_player, rank, successful_rank)
            result = action.to_s(player_parameter)
            expect(result).to eq "You successfully got a #{successful_rank} from the deck"
          end
        end
      end

      context 'with other player' do
        let(:player_parameter) { other_player }

        context 'when unsuccessful' do
          let(:unsuccessful_rank) { '5' }

          it 'displays a message a card was grabbed' do
            action = DeckAction.new(current_player, rank, unsuccessful_rank)
            result = action.to_s(player_parameter)
            expect(result).to eq "#{current_player.name} got a card from the deck"
          end
        end

        context 'when successful' do
          let(:successful_rank) { rank }

          it 'displays the card' do
            action = DeckAction.new(current_player, rank, successful_rank)
            result = action.to_s(player_parameter)
            expect(result).to eq "#{current_player.name} successfully got a #{successful_rank} from the deck"
          end
        end
      end
    end
  end
end
