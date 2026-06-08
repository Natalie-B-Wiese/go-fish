class ClientMessage
  attr_accessor :has_sent, :value

  def initialize
    @has_sent = false
    @value = nil
  end

  def reset
    self.has_sent = false
    self.value = nil
  end

  def send
    self.has_sent = true
  end

  def sent?
    !!has_sent
  end

  def value?
    true?
  end

  def true?
    !!value
  end
end
