require_relative '../lib/action_logs/action'
require_relative '../lib/player'

# initialize(current_player:, opponent_player: nil, rank_requested: nil,
#                 cards_received: [], was_book_made: false)
describe Action do
  describe '#message' do
    let(:current_player_name) { 'Jeff' }
    let(:current_player) { Player.new(current_player_name) }
    let(:calling_player) { Player.new('Bob') }

    context 'book_made? true' do
      let(:book_regex) { /#{current_player_name}([a-zA-Z]*\s*)*book(\.|!)/ }
      it 'contains a book message' do
        action = Action.new(current_player: current_player, was_book_made: true)
        result = action.message(calling_player)
        expect(result).to match(book_regex)
      end
    end
  end
end
