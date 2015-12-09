require "socket"
$LOAD_PATH << '.'
require "rooms"

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Array.new
    @clients = Hash.new
    @room_id = 1
    @join_id = 1
    @alive = TRUE
    @connections[:server] = @server
    @connections[:chatrooms] = Hash.new
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        @join_id += 1
        firstline = client.gets
        puts "#{firstline}"
        if firstline.include? "KILL_SERVICE" then
          client.close
          @server.close
          puts "Successfully deleted"
        elsif firstline.include? "HELO" then
          response_neccessary(client, $port, firstline)
        elsif firstline.include? "JOIN_CHATROOM" then
          chatroom_name = firstline.sub!(/^JOIN_CHATROOM: /, "")
          chatroom_name = chatroom_name.strip
          client_ip = client.gets
          port = client.gets
          client_name = client.gets
          client_name = client_name.sub!(/\s+CLIENT_NAME: /, "")
          client_name = client_name.strip
        end
       #client.close                            # Disconnect from the client
            
        if @rooms.empty?
          puts "#{@room_id}"
          room_obj = Room.new(chatroom_name, client_name, client, @room_id, @join_id)
          @room_id += 1
          client.puts"room_id is getting incremented"
        else
          @rooms.each do |x| #@connections[:chatrooms].each do |x|
            if x.name == chatroom_name
              client.puts "Trying to add #{client_name}"
              x.add( chatroom_name, client_name, client, @join_id )
            else
              room_obj = Room.new(chatroom_name, client_name, client, @room_id, @join_id)
              @room_id += 1
              client.puts"room_id is getting incremented"
            end
          end
        end

        @rooms << room_obj

        @rooms.each do |x|
          puts "#{x.inspect}"
        end

        client.puts "Connection established, You have joined chatroom, #{chatroom_name}, with chatroom id, id"
        listen_user_messages( client_name, client )
      end
    }.join
  end
 
 end
  
def response_neccessary(client, port, line)
  client.puts "#{line}" + "IP:#{get_ip_address()}\nPort:#{port}\nStudentID:02484893aa070fa3e7d2f5b2d14c90823425659e554bab3ddb69890974f95ada\n"
  client.close
end

def get_ip_address()
  return "52.91.206.5"
  #return open('http://whatismyip.akamai.com').read
  #Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
end

$hostname = '0.0.0.0'
$port = ARGV[0] #80
Server.new( $port, $hostname )
