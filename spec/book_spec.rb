require_relative '../lib/book'

describe Book do
  describe '#initialize' do
    it 'has a value' do
      value = 6
      book = described_class.new(value)
      expect(book.value).to eq value
    end

    it 'throws an error if value is not an integer' do
      expect do
        value = 'K'
        described_class.new(value)
      end.to raise_error Book::InvalidValue
    end
  end
end
