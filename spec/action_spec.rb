require_relative '../lib/action_logs/action'
require_relative '../lib/player'

# initialize(current_player:, opponent_player: nil, rank_requested: nil,
#                 cards_received: [], was_book_made: false)
describe Action do
  describe '#message' do
    let(:current_player) { Player.new('Jeff') }
    let(:calling_player) { Player.new('Bob') }

    context 'book_made? true' do
      it 'is a book message' do
        action = Action.new(current_player: current_player, was_book_made: true)
        result = action.message(calling_player)
        expect(result).to match(/book/i)
      end
    end
  end
end
