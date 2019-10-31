require 'socket'

class Test
   def initialize(socket,user)
     @socketUser1 = socket
     @i = user
     @request = send_request
     @response = listen_response
     @request.join
     @response.join
    end

def send_request

        @socketUser1.puts "user#{@i}"                               # RESULTS #
# SET
        @socketUser1.puts "set key0 1 900 13"
        @socketUser1.puts "valor de key0"                            # STORED
        @socketUser1.puts "set key1 10 0 13"
        @socketUser1.puts "valor de key1"                            # STORED
        @socketUser1.puts "get key0 key1"                            # VALUES of both keys

        @socketUser1.puts "set key2 flags 13 8"                      # CLIENT_ERROR
        @socketUser1.puts "set key2 0 13 8 12 34 0"                  # CLIENT_ERROR
        @socketUser1.puts "set key2 12 900 13"
        @socketUser1.puts "largo del data_block no correcto"         # CLIENT_ERROR


# ADD
        @socketUser1.puts "add key2 10 30 13"
        @socketUser1.puts "valor de key2"                            # STORED
        @socketUser1.puts "get key0 key1 key2 "                      # VALUES of all three keys

        @socketUser1.puts "add key1 10 5 24"
        @socketUser1.puts "ya existe data para key1"                 #NOT_STORED
        @socketUser1.puts "addd key3 10 5 20"
        @socketUser1.puts "comando no existente"                     #ERROR \r CLIENT_ERROR bad command line format


# APPEND
        @socketUser1.puts "append key1 0 1 18"                       # STORED
        @socketUser1.puts "adjuntar contenido"


# PREPEND
        @socketUser1.puts "prepend key0 0 1 19"
        @socketUser1.puts "anteponer contenido"                      # STORED
        @socketUser1.puts "prepend key1 0 1 19"
        @socketUser1.puts "anteponer contenido"                      # STORED
        @socketUser1.puts "gets key0 key1 key2"                      # VALUES of all three keys with unique_token


# REPLACE
        @socketUser1.puts "replace key2 0 0 20 "
        @socketUser1.puts "otro valor para key2"                     # STORED
        @socketUser1.puts "replace key2 0 0 22 noreply"
        @socketUser1.puts "tercer valor para key2"                   #NO RESPONSE
        @socketUser1.puts "gets key2"                                # VALUE of key2 with unique_toquen

        
# CAS
        @socketUser1.puts "cas key2 2 500 33 5 "                     #comment#  = 5 is the last unique_toquen of key2
        @socketUser1.puts "otro valor para key2 mediante cas"        # STORED

        @socketUser1.puts "cas key2 0 0 23 8 "
        @socketUser1.puts "diferente unique_toquen"                  # EXISTS

end

def listen_response
         loop do
            response = @socketUser1.gets.chomp
            puts "#{response}"
            if response.eql?'quit'
               @socketUser1.close
            end
         end
end

end

socket = TCPSocket.open( "localhost", 2000 )
Test.new( socket,1)
