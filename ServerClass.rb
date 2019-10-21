require 'socket'
require 'dalli'


class Server
   def initialize(socket_address, socket_port)
      @server_socket = TCPServer.open(socket_port, socket_address)

      @connections_details = Hash.new
      @connected_clients = Hash.new

      @datas = Hash.new


      @connections_details[:server] = @server_socket
      @connections_details[:clients] = @connected_clients
      @connected_clients[:datas] = @datas

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
            puts client_connection
            puts conn
            puts @connections_details[:server]
            puts @connections_details[:clients]
            puts @connected_clients
            establish_chatting(conn_name, conn) # allow chatting
         end
       }
   end

   def establish_chatting(username, connection)
      loop do
         message = connection.gets.chomp
         puts @connections_details[:clients]
          @connections_details[:clients][username].puts "#{username} : #{message}"
          command = message.split.first
          key = message.split[2]
          data = message.split(' ')[2..-1].join(' ')
          response = manage_data(username,command,key,data)
          @connections_details[:clients][username].puts response
          #@connected_clients[:data][command]= message.split(' ')[1..-1].join(' ')
         end
      end

   def manage_data(username,command,key,data)
     case command
      when 'set'
        @conections_details[:clients][username][:datas][:key] = key
      when 'add'
        @conections_details[:clients][username][:datas][:key] = key
      when 'get'
        return @conections_details[:clients][username][:datas][:key][key]
      when 'append'

      when 'prepend'

      when 'replace'

      when 'cas'
    end
  end
end


Server.new( 2000, "localhost" )
