class Room
  def initialize(chatroom_name, client_name, client, room_id, join_id)
    @room_name = chatroom_name
    @room_id = room_id
    @clients = Hash.new
    @room = Hash.new
    @room[:clients] = @clients
    add(chatroom_name, client_name, client, join_id)
  end

  def add( chatroom_name, username, client_connection, join_id)
    @room[:clients][username] = client_connection
    client_connection.puts "JOINED_CHATROOM: #{chatroom_name}\nSERVER_IP: #{get_ip_address()}\nPORT: 80\nROOM_REF: #{@room_id}\nJOIN_ID: #{join_id}"
    @room[:clients].each do | name, connection |
	  connection.puts"CHAT: #{@room_id}\nCLIENT_NAME: #{username}\nMESSAGE: #{username} has joined this chatroom.\n\n"
    end
    #listen_user_messages(username, client_connection)
  end
  
  def propagate_message( client, username, msg )
      puts "#{msg}"
    if msg.include? "LEAVE_CHATROOM"
      leave_chatroom(msg, client )
    end
    @room[:clients].each do |other_name, other_client|
      unless other_name == username
        other_client.puts "#{username}: #{msg}"
      end
    end
  end
    

  def leave_chatroom(msgline1, client)
    puts "#{msgline1}"
    room_leaving = msgline1.sub!(/LEAVE_CHATROOM:/, "")
    join_id = client.gets
    join_id = join_id.sub!(/JOIN_ID:/, "")
    client_name = client.gets
    client_name = client_name.sub!(/CLIENT_NAME:/, "")
    puts "I've reached here"
    @rooms.each do |x|
      puts "#{x.inspect}"
      puts "Hello"
    end
    
    @room[:clients].each do |name, connection|
      #unless other_name == username
        #client.puts "LEFT_CHATROOM: #{@room_id}\nJOIN_ID: #{join_id}"
        puts "LEFT_CHATROOM: #{@room_id}\nJOIN_ID: #{join_id}"
      #end
    end
  end
    
  def name
    @room_name
  end
  
  def room
    @room[:clients]
  end
end

def get_ip_address()
  return "52.91.239.246"
  #return open('http://whatismyip.akamai.com').read
  #Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
end