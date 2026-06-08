class ActionLog
  attr_accessor :log

  def initialize
    @log = []
  end

  def push(item)
    log.push(item)
  end

  def most_recent
    log[-1]
  end
end
