#----------Executables----------

decipher: decipher.o chiffrement.o
	gcc decipher.o chiffrement.o -o decipher

findkey: findkey.o chiffrement.o
	gcc findkey.o chiffrement.o -o findkey

#----------Objets----------

decipher.o: decipher.c chiffrement.h
	gcc -c decipher.c

findkey.o: findkey.c chiffrement.h
	gcc -c findkey.c

chiffrement.o: chiffrement.c chiffrement.h
	gcc -c chiffrement.c

#----------Création----------

all: decipher findkey

#----------Nettoyage----------

clean_all:
	rm -f *.o decipher findkey

clean_o:
	rm -f *.o
