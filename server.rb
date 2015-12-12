  
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
        firstline = client.gets.chomp
        puts "#{firstline}"
        if firstline.include? "KILL_SERVICE" then
          client.close
          @server.close
          puts "Successfully deleted"
        elsif firstline.include? "HELO" then
          response_neccessary(client, firstline)
        elsif firstline.include? "JOIN_CHATROOM" then
          room_obj = join_chatroom(firstline, client)

          loop {
            msg = client.gets.chomp
            puts "#{msg}"
            if msg.include? "LEAVE_CHATROOM"
              room_leaving = msg.sub!(/LEAVE_CHATROOM:/, "")
              join_id = client.gets.chomp
              join_id = join_id.sub!(/JOIN_ID:/, "")
              client_name = client.gets.chomp
              client_name = client_name.sub!(/CLIENT_NAME:/, "")
              client.puts "LEFT_CHATROOM: #{room_leaving}\nJOIN_ID: #{join_id}\n"
              client.puts "CHAT: #{room_leaving}\nCLIENT_NAME: #{client_name}\nMESSAGE: #{client_name} has left this chatroom.\n\n"
              #client.puts "CHAT: #{room_leaving}\nCLIENT_NAME: #{client_name}\nMESSAGE: #{message}\n\n"
              #room_obj.room.each do |other_name, other_client|
              #  unless other_client == client
                  #other_client.puts "CHAT: #{room_leaving}\nCLIENT_NAME: #{client_name}\nMESSAGE: #{client_name} has left this chatroom.\n\n"
              #  end
              #end
            elsif msg.include? "CHAT:"
              puts "CHAT: I've reached here"
              room_ref = msg.sub!(/CHAT:/, "")
              join_id = client.gets.chomp
              client_name = client.gets.chomp
              client_name = client_name.sub!(/CLIENT_NAME:/, "")
              message = client.gets
              room_obj.room.each do |other_name, client|
                #unless other_name == client_name
                  client.puts "CHAT: #{room_ref}\nCLIENT_NAME: #{client_name}\nMESSAGE: #{message}\n\n"
                #end
              end
            elsif msg.include? "JOIN_CHATROOM"
              puts "I've reached here"
              join_chatroom(msg, client)
            end
          }
        end
      end
    }.join
  end
end

def join_chatroom(firstline, client)
  chatroom_name = firstline.sub!(/^JOIN_CHATROOM:/, "")
  client_ip = client.gets.chomp
  client_ip = client_ip.sub!(/CLIENT_IP:/, "")
  port = client.gets.chomp
  port = port.sub!(/PORT:/, "")
  client_name = client.gets.chomp
  client_name = client_name.sub!(/CLIENT_NAME:/, "") #name.sub!(/\s+CLIENT_NAME:/, "")
  
  if @rooms.empty?
    puts "I've reached here empty"
    room_obj = Room.new(chatroom_name, client_name, client, @room_id, @join_id)
    @rooms << room_obj
    @room_id += 1
    return room_obj
  else
    @rooms.each do |x| #@connections[:chatrooms].each do |x|
      if x.room_name == chatroom_name
        puts "I've reached here add"
        x.add( chatroom_name, client_name, client, @join_id )
        room_obj = x
        return room_obj
      end
    end
  end
      puts "I've reached here else"
      room_obj = Room.new(chatroom_name, client_name, client, @room_id, @join_id)
      @rooms << room_obj
      @room_id += 1
  
  @rooms.each do |x|
    puts "#{x.inspect}"
    puts "#{x.room}"
  end
  
 return room_obj
end

def response_neccessary(client, line)
  client.puts "#{line}" + "IP:#{get_ip_address()}\nPort:#{$port}\nStudentID:02484893aa070fa3e7d2f5b2d14c90823425659e554bab3ddb69890974f95ada\n"
  client.close
end

def get_ip_address()
  return "52.90.104.247"
  #return open('http://whatismyip.akamai.com').read
  #Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
end

$hostname = '0.0.0.0'
$port = ARGV[0] #80
Server.new( $port, $hostname )
