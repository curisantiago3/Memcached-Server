Memcached-Server para Moove-It

El proyecto se implementó con la version de ruby 2.6.5p114
Está compuesto por 5 archivos: ServerClass,DataHandler,DataClass,ClientClass,test


Run server:
	abrir command prompt(terminal) en la carpeta del proyecto y correr el siguiente comando:
	ruby ServerClass.rb
	
	El socket del servidor esta abierto para el puerto 2000

Run demo Client:
	abrir command prompt(terminal) en la carpeta del proyecto y correr el siguiente comando:
	ruby ClientClass.rb

	Si se desea conectar varios clientes al mismo servidor se debe repetir el proceso en
	diferentes terminales.

Run test:
	abrir command prompt(terminal) en la carpeta del proyecto y correr el siguiente comando:
	ruby test.rb
	
	test.rb es un archivo donde simula ser un cliente estático el cual utiliza todos los 
	comandos requeridos(set,add,prepend,append,replace,cas,get,gets). A su vez envia comandos
	no existentes o mal formados según el protocolo especificado para obtener los mensajes
	de error correspondientes.