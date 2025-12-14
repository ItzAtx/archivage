#----------Bibliothèque statique----------

libchiffrement.a: chiffrement.o
	ar rcs libchiffrement.a chiffrement.o


#----------Executables----------

cipher: cipher.o libchiffrement.a
	gcc cipher.o libchiffrement.a -o cipher

decipher: decipher.o libchiffrement.a
	gcc decipher.o libchiffrement.a -o decipher

findkey: findkey.o libchiffrement.a
	gcc findkey.o libchiffrement.a -o findkey

cipher_total: cipher_total.o libchiffrement.a
	gcc cipher_total.o libchiffrement.a -o cipher_total

decipher_total: decipher_total.o libchiffrement.a
	gcc decipher_total.o libchiffrement.a -o decipher_total

findkey_total: findkey_total.o libchiffrement.a
	gcc findkey_total.o libchiffrement.a -o findkey_total

#----------Objets----------

cipher.o: cipher.c chiffrement.h
	gcc -c cipher.c

decipher.o: decipher.c chiffrement.h
	gcc -c decipher.c

findkey.o: findkey.c chiffrement.h
	gcc -c findkey.c

cipher_total.o: cipher_total.c chiffrement.h
	gcc -c cipher_total.c

decipher_total.o: decipher_total.c chiffrement.h
	gcc -c decipher_total.c

chiffrement.o: chiffrement.c chiffrement.h
	gcc -c chiffrement.c

findkey_total.o: findkey_total.c chiffrement.h
	gcc -c findkey_total.c
#----------Création----------

all: libchiffrement.a cipher decipher findkey cipher_total decipher_total findkey_total

lib: libchiffrement.a


#----------Nettoyage----------

clean_all:
	rm -f *.o cipher decipher findkey cipher_total decipher_total findkey_total libchiffrement.a

clean_o:
	rm -f *.o
