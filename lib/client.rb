require 'socket'

class Client
  attr_reader :socket, :name

  def initialize(socket, name)
    @socket = socket
    @name = name
    @is_ready = false
    @is_message_sent = false
    @is_waiting_message_sent = false
  end

  def puts(message)
    socket.puts(message)
  end

  def check_ready!
    return if ready?

    socket.puts 'Are you ready? ->' unless received_message?
    self.is_message_sent = true
    self.is_ready = !read_socket.empty?
  end

  def read_socket
    socket.read_nonblock(1000)
  rescue IO::WaitReadable
    ''
  end
end
