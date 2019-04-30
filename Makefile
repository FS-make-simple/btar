VERSION=1.1.1 [$(shell if test -f manifest.uuid; then cat manifest.uuid | cut -c -10 ; else echo undefined; fi)]
CFLAGS+=-DVERSION="$(VERSION)" -D_FILE_OFFSET_BITS=64 -g -Wall -Wextra

PREFIX?=/usr/local

# Comment the following lines if you don't have librsync
LIBRSYNC_CFLAGS=-DWITH_LIBRSYNC
LIBRSYNC_LDFLAGS=-lrsync


# ----------------------
CFLAGS+=$(LIBRSYNC_CFLAGS)
LDFLAGS+=$(LIBRSYNC_LDFLAGS)

OBJECTS=src/main.o src/mytar.o src/traverse.o src/error.o src/loadindex.o src/filters.o \
	   	src/index_from_tar.o src/block.o src/blockprocess.o src/filememory.o \
		src/readtar.o src/extract.o src/listindex.o src/rsync.o src/string.o

btar: $(OBJECTS)
	$(CC)  -o $@ $^ $(LDFLAGS)

install: btar
	mkdir -p $(PREFIX)/bin
	cp btar $(PREFIX)/bin
	mkdir -p $(PREFIX)/share/man/man1
	cp btar.1 $(PREFIX)/share/man/man1

all: btar fnmatchtest rsynctest loadindextest

clean:
	rm -f $(OBJECTS) btar fnmatchtest loadindextest rsynctest

src/main.o: src/main.c src/main.h src/traverse.h src/mytar.h src/loadindex.h src/filters.h src/block.h src/blockprocess.h
src/traverse.o: src/traverse.c src/main.h src/traverse.h src/mytar.h
src/mytar.o: src/mytar.c src/main.h src/mytar.h
src/error.o: src/error.c src/main.h
src/loadindex.o: src/loadindex.c src/mytar.h src/main.h src/loadindex.h
src/filters.o: src/filters.c src/filters.h src/main.h
src/index_from_tar.o: src/index_from_tar.c src/filters.h src/mytar.h src/main.h
src/block.o: src/block.c src/block.h
src/blockprocess.o: src/blockprocess.c src/blockprocess.h src/block.h src/main.h src/mytar.h
src/filememory.o: src/filememory.c src/filememory.h src/block.h src/main.h src/mytar.h
src/rsync.o: src/rsync.c src/rsync.h src/main.h
src/rsynctest.o: src/rsynctest.c src/rsync.h src/main.h
src/readtar.o: src/readtar.c src/readtar.h src/main.h src/mytar.h
src/extract.o: src/extract.c src/extract.h src/main.h src/readtar.h src/mytar.h
src/listindex.o: src/listindex.c src/listindex.h src/main.h src/readtar.h src/mytar.h
src/string.o: src/string.c src/main.h

loadindextest: src/loadindextest.o src/error.o src/mytar.o src/readtar.o

rsynctest: src/rsynctest.o src/rsync.o src/error.o

src/loadindextest.o: src/loadindex.c src/mytar.h src/main.h src/loadindex.h
	$(CC) $(CFLAGS) -DINDEXTEST -c -o $@ $<

fnmatchtest: src/fnmatchtest.o

xortest: src/xortest.o
