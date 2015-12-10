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
        firstline = client.gets
        puts "#{firstline}"
        if firstline.include? "KILL_SERVICE" then
          client.close
          @server.close
          puts "Successfully deleted"
        elsif firstline.include? "HELO" then
          response_neccessary(client, firstline)
        elsif firstline.include? "JOIN_CHATROOM" then
          chatroom_name = firstline.sub!(/^JOIN_CHATROOM:/, "")
          chatroom_name = chatroom_name.strip
          puts "#{chatroom_name}"
          client_ip = client.gets
          client_ip = client_ip.sub!(/CLIENT_IP:/, "")
          client_ip = client_ip.strip
          puts "#{client_ip}"
          port = client.gets
          port = port.sub!(/PORT:/, "")
          port = port.strip
          puts "#{port}"
          client_name = client.gets
          client_name = client_name.sub!(/CLIENT_NAME:/, "") #name.sub!(/\s+CLIENT_NAME:/, "")
          client_name = client_name.strip
          puts "#{client_name}"
  
          if @rooms.empty?
            room_obj = Room.new(chatroom_name, client_name, client, @room_id, @join_id)
            @rooms << room_obj
            @room_id += 1
          else
            @rooms.each do |x| #@connections[:chatrooms].each do |x|
              if x.name == chatroom_name
                x.add( chatroom_name, client_name, client, @join_id )
                room_obj = x
              else
                room_obj = Room.new(chatroom_name, client_name, client, @room_id, @join_id)
                @rooms << room_obj
                @room_id += 1
              end
            end
          end

          @rooms.each do |x|
            puts "#{x.inspect}"
            puts "#{x.room}"
          end
          
          @join_id += 1

          loop {
            msg = client.gets.chomp
            if msg.include? "LEAVE_CHATROOM"
              room_leaving = msg.sub!(/LEAVE_CHATROOM:/, "")
              join_id = client.gets.chomp
              join_id = join_id.sub!(/JOIN_ID:/, "")
              client_name = client.gets.chomp
              client_name = client_name.sub!(/CLIENT_NAME:/, "")
              puts "I've reached here"
              room_obj.room.each do |other_name, client|
                client.puts "LEFT_CHATROOM: #{@room_id}\nJOIN_ID: #{join_id}
              end
            end
            else
              room_ref = msg.sub!(/CHAT:/, "")
              join_id = client.gets.chomp
              client_name = client.gets.chomp
              client_name = client_name.sub!(/CLIENT_NAME:/, "")
              message = client.gets
              puts "#{message}"
              room_obj.room.each do |other_name, client|
                #unless other_name == client_name
                  client.puts "CHAT: #{room_ref}\nCLIENT_NAME: #{client_name}\nMESSAGE: #{message}\n"
                #end
              end
            end
            }
          end
        end
    }.join
  end

end
  
def response_neccessary(client, line)
  client.puts "#{line}" + "IP:#{get_ip_address()}\nPort:#{$port}\nStudentID:02484893aa070fa3e7d2f5b2d14c90823425659e554bab3ddb69890974f95ada\n"
  client.close
end

def get_ip_address()
  return "52.165.159.206"
  #return open('http://whatismyip.akamai.com').read
  #Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
end

$hostname = '0.0.0.0'
$port = ARGV[0] #80
Server.new( $port, $hostname )
