class Room
  def initialize(chatroom_name, client_name, client)
  	@@room_id_incrementer
    @room_name = chatroom_name
    @room_id
    @clients = Hash.new
    @room = Hash.new
    @room[:clients] = @clients

    add(client_name, client)
  end

  def propagate_message( username, client )
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username.to_s}: #{msg}"
        end
      end
    }
    end
  #end

  def add( username, client_connection)
    @room[:clients][username] = client_connection

    @room[:clients].each do | name, connection |
	  unless name == username || connection == client_connection
        connection.puts"#{username} has joined the conversation"
      end
    end
  end

  def listen_user_messages(username, client, rooms)
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username.to_s}: #{msg}"
        end
      end
      }
    end
  #end

  def name
    @room_name
  end
end
