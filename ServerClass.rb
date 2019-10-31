require 'socket'
require_relative 'DataHandler'

class Server
   def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_port, socket_address)

      @connections_details = Hash.new
      @connected_clients = Hash.new
      @data_hash = Data_handler.new()

      @connections_details[:server] = @server_socket
      @connections_details[:clients] = @connected_clients

      puts 'Started server.........'
      run

   end

   def run
      loop{
           client_connection = @server_socket.accept
           Thread.start(client_connection) do |conn| # open thread for each accepted connection
            conn_name = conn.gets.chomp.to_sym
            if(@connections_details[:clients][conn_name] != nil) # avoid connection if user exits
               conn.puts "This username already exist"
               conn.puts "quit"
               conn.kill self
            end

            puts "Connection established #{conn_name} => #{conn}"
            @connections_details[:clients][conn_name] = conn
            conn.puts "Connection established successfully #{conn_name} => #{conn}, use memcached commands to manage your data"
            loop do
               message = conn.gets.chomp
               if( isCorrect(message.split(' ')[0..-1]))  #check if command line is correct
                 manage_data(message,conn)
               else
                 conn.puts "CLIENT_ERROR bad command line format"
               end
            end
           end
       }
   end

   def isCorrect(message) #check if command line is correct through specific protocol
     if (message[0] == "get") || (message[0] == "gets")
       return true
     else
       flag = (is_number?(message[2])) && (is_number?(message[3])) && (is_number?(message[4]))
       if (message[0] == 'cas')
         return ( ((message.size() == 6)||(message.size() == 7 if message[6].eql?'noreply')) && flag )
       else
         return ( ((message.size() == 5)||(message.size() == 6 if message[5].eql?'noreply')) && flag )
       end
     end
   end


   def manage_data(message,connection)
     command = message.split.first
     key = message.split[1]
     data = message.split(' ')[1..-1]
     case command

########## STORAGE ##########

      when 'set'
        data_block = connection.read(data[3].to_i).chomp
        rest = connection.gets.chomp
        if (rest.length == 0) #data is not bigger than it should be
          connection.puts @data_hash.set(key,data,data_block)
        else
          connection.puts "CLIENT_ERROR bad data chunk"
        end

      when 'add'
        data_block = connection.read(data[3].to_i).chomp
        rest = connection.gets.chomp
        if (rest.length == 0)
          connection.puts @data_hash.add(key,data,data_block)
        else
          connection.puts "CLIENT_ERROR bad data chunk"
        end

      when 'replace'
        data_block = connection.read(data[3].to_i).chomp
        rest = connection.gets.chomp
        if (rest.length == 0)
          connection.puts @data_hash.replace(key,data,data_block)
        else
          connection.puts "CLIENT_ERROR bad data chunk"
        end

      when 'append'
        data_block = connection.read(data[3].to_i).chomp
        rest = connection.gets.chomp
        if (rest.length == 0)
          connection.puts @data_hash.append(key,data,data_block)
        else
          connection.puts "CLIENT_ERROR bad data chunk"
        end

      when 'prepend'
        data_block = connection.read(data[3].to_i).chomp
        rest = connection.gets.chomp
        if (rest.length == 0)
          connection.puts @data_hash.prepend(key,data,data_block)
        else
          connection.puts "CLIENT_ERROR bad data chunk"
        end

      when 'cas'
        data_block = connection.read(data[3].to_i).chomp
        rest = connection.gets.chomp
        if (rest.length == 0)
          connection.puts @data_hash.cas(key,data,data_block)
        else
          connection.puts "CLIENT_ERROR bad data chunk"
        end

########## RECIEVE ##########

      when 'get'
        keys = message.split(' ')[1..-1]
        keys.each do |key|
          if (@data_hash.get(key)!=nil)
            connection.puts "VALUE #{@data_hash.get(key)}"
            connection.puts @data_hash.getBlock(key)
          end
        end
        connection.puts "END"

      when 'gets'
        keys = message.split(' ')[1..-1]
        keys.each do |key|
          if (@data_hash.get(key)!=nil)
            connection.puts "VALUE #{@data_hash.gets(key)}"
            connection.puts @data_hash.getBlock(key)
          end
        end
        connection.puts "END"

     else
        connection.puts "ERROR"
    end
########## UPDATE EXPIRED KEYS ##########
    @data_hash.deleteExpired()
  end

########## AUX FUNCTION ##########
  def is_number? (string)
    true if Float(string) rescue false
  end

end

puts "To customize the TCP connection write 'config', if not the server will open in <11211><127.0.0.1>"
config = $stdin.gets.chomp
port = 11211
ip = "127.0.0.1"
if(config.eql?'config')
  puts "Write port: "
  port = $stdin.gets.chomp.to_i
  puts "Write ip: "
  ip = $stdin.gets.chomp
end
Server.new( port, ip )
