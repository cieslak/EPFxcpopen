CC=clang

FRAMEWORKS:= -framework Foundation -framework Cocoa
LIBRARIES:= -lobjc

SOURCE=xcpopen/main.m

CFLAGS=-Wall -Werror -g -v $(SOURCE)
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o bin/xcpopen

all:
	mkdir -p bin 
	$(CC) $(CFLAGS) $(LDFLAGS) $(OUT)
	
install:
	mkdir -p $(DESTDIR)/bin
	cp bin/xcpopen $(DESTDIR)/bin/xcpopen