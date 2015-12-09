require "socket"
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    #base_test
    #kill_test
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end

  def base_test
  @server.puts( "HELO BASE_TEST" )
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end

  def kill_test
  @server.puts( "KILL_SERVICE" )
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end

  def send
    puts "To join a chatroom please enter the chatroom name: "
    chatroom_name = $stdin.gets.chomp
    puts "Please enter your name(identifier): "
    client_name = $stdin.gets.chomp
    join_cmd = "JOIN_CHATROOM: #{chatroom_name}
      CLIENT_IP: 0
      PORT: 0
      CLIENT_NAME: #{client_name}"
    #puts "#{join_cmd}"
    @server.puts( join_cmd )
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "52.91.206.5", 80 ) #URLumkke9ec83ab.mcalistj.koding.io #54.174.198.134
Client.new( server )