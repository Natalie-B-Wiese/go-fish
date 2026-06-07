class Player
  attr_reader :name
  attr_accessor :cards

  def initialize(name)
    @name = name
    @cards = []
  end

  def add_card(card)
    @cards.push(card)
  end

  def add_cards(card_array)
    card_array.each { |card| add_card(card) }
  end

  def take_cards_with_rank(rank)
    cards_taken = cards_with_rank(rank)
    self.cards -= cards_taken
    cards_taken
  end

  def card_count
    cards.length
  end

  def out_of_cards?
    cards.empty?
  end

  def includes_card_with_rank?(rank)
    !cards_with_rank(rank).empty?
  end

  def cards_to_s
    cards.map(&:rank).join(' ')
  end

  private

  def cards_with_rank(rank)
    cards.select { |card| card.rank == rank }
  end
end
