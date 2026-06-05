require 'socket'

class Client
  INPUT_SYMBOL = '->'

  attr_reader :socket, :name
  attr_accessor :is_ready, :is_ready_sent

  def initialize(socket, name)
    @socket = socket
    @name = name
    @is_ready = false
    @is_ready_sent = false
  end

  def ready?
    !!is_ready
  end

  def received_ready?
    !!is_ready_sent
  end

  def puts(message)
    socket.puts(message)
  end

  def ask(message)
    socket.puts(message + INPUT_SYMBOL)
  end

  def check_ready!
    return if ready?

    ask('Press ENTER when you are ready') unless received_ready?
    self.is_ready_sent = true
    self.is_ready = !read_socket.empty?
  end

  def read_socket
    socket.read_nonblock(1000)
  rescue IO::WaitReadable
    ''
  end
end
