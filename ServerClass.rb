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
               manage_data(message,conn)
               end
             end
       }
   end


   def manage_data(message,connection)
     command = message.split.first
     key = message.split[1]
     data = message.split(' ')[2..-1]
     case command
      when 'set'
        data_block = connection.read(data[2].to_i)
        connection.puts @data_hash.set(key,data,data_block)

      when 'add'
        data_block = connection.read(data[2].to_i)
        connection.puts @data_hash.add(key,data,data_block)

      when 'replace'
        connection.puts @data_hash.replace(key,data)

      when 'append'
        data_block = connection.read(data[2].to_i)
        connection.puts @data_hash.append(key,data,data_block)

      when 'prepend'
        data_block = connection.read(data[2].to_i)
        connection.puts @data_hash.prepend(key,data,data_block)

      when 'cas'
          data_block = connection.read(data[2].to_i)
          connection.puts @data_hash.cas(key,data,data_block)


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
    @data_hash.deleteExpired()
  end

end

Server.new( 2000, "localhost" )
