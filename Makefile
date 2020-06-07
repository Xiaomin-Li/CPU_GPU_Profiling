all:
	cd cpu; make
	cd gpu; make
install:
	cd cpu; ./install.sh
	cd gpu; ./install.sh
clean:
	cd cpu; make clean
	cd gpu; make clean
