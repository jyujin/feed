BINARIES:=bin/feedd bin/feed bin/feedc
INCLUDES:=$(wildcard include/feed/*.h)
MANPAGES:=$(addprefix share/man/man1/,$(notdir $(wildcard src/*.1)))
DATAHEADERS:=include/feed/data-feed.h include/feed/data-update1to2.h include/feed/data-update2to3.h
INSTALLTARGETS:=$(BINARIES) $(INCLUDES) $(MANPAGES) $(DATAHEADERS)
TARGETS:=$(BINARIES) include/feed/data-feed.h
DESTDIR:=
PREFIX:=/usr/local
DEST:=$(DESTDIR)$(PREFIX)
VERSION:=2

# programmes
SQLITE3:=sqlite3
INSTALL:=install
CXX:=clang++
CC:=clang
PKGCONFIG:=pkg-config
INSTALL:=install
CURL:=curl
UNZIP:=unzip

# SQLITE3
SQLITE3ZIPSRC:=http://www.sqlite.org/2013/sqlite-amalgamation-3071700.zip
SQLITE3CFLAGS:=-DSQLITE_OMIT_LOAD_EXTENSION

# paths, etc
INCLUDES:=include
LIBRARIES:=libcurl libxml-2.0

# boost libraries
BOOSTLIBDIR:=
BOOSTLIBRARIES:=regex

# flags
CCFLAGS:=$(addprefix -I,$(INCLUDES)) $(addprefix -I,$(BOOSTLIBDIR))
PCCFLAGS:=$(shell $(PKGCONFIG) --cflags $(LIBRARIES)) $(SQLITE3CFLAGS)
PCLDFLAGS:=$(shell $(PKGCONFIG) --libs $(LIBRARIES)) $(addprefix -lboost_,$(BOOSTLIBRARIES)) sqlite3.o
CXXFLAGS:=-O3
CFLAGS:=-O3
LDFLAGS:=
CXXR:=$(CXX) $(CCFLAGS) $(PCCFLAGS) $(CXXFLAGS)
CR:=$(CC) $(CCFLAGS) $(PCCFLAGS) $(CFLAGS) $(LDFLAGS) $(PCLDFLAGS)

# meta rules
all: $(TARGETS)

.SECONDARY:

clean:
	rm -f data.feed* $(TARGETS) sqlite3.o sqlite3.zip

clean-binaries:
	rm -f $(BINARIES)

install: $(addprefix $(DEST)/,$(INSTALLTARGETS)) $(DESTDIR)/etc/profile.d/feed.sh

uninstall:
	rm -f $(addprefix $(DEST)/,$(INSTALLTARGETS)) $(DESTDIR)/etc/profile.d/feed.sh

archive: ../feed-$(VERSION).tar.gz
archive-debian: ../feed_$(VERSION).orig.tar.gz

package-debian: archive-debian
	debuild -us -uc

../feed%.tar.gz:
	git archive --format=tar --prefix=feed-$(VERSION)/ HEAD | gzip -9 >$@

$(DEST)/%: %
	$(INSTALL) -D $< $@

$(DEST)/share/man/man1/%.1: src/%.1
	$(INSTALL) -D $< $@

$(DESTDIR)/etc/profile.d/%: src/%
	$(INSTALL) -D $< $@

data.feed: src/feed.sql
	rm -f $@*
	$(SQLITE3) $@ < $<

reset:
	$(SQLITE3) $${FEED_DATABASE} 'update option set value=$(VERSION) where otid=-1'

bin/.volatile:
	mkdir $(dir $@); true
	touch $@

bin/%: src/%.c++ bin/.volatile $(DATAHEADERS) sqlite3.o
	$(CXXR) $< $(LDFLAGS) $(PCLDFLAGS) -o $@

sqlite3.o: src/sqlite3.c
	$(CC) $(CFLAGS) $(SQLITE3CFLAGS) -c $< -o $@

sqlite3.zip:
	curl "$(SQLITE3ZIPSRC)" -o $@

src/sqlite3.c: sqlite3.zip
	cd src && $(UNZIP) -jo ../sqlite3.zip
	mv src/sqlite3.h include/sqlite3.h
	touch $@

include/feed/data-%.h: src/%.sql
	echo '/* autogenerated data file, based on $< */' > $@
	echo "namespace feed { namespace data { static const char $*[] = \"$$(sed -e ':a;N;$$!ba;s/\n/\\\\n/g' -e 's/"/\\"/g' $<)\"; } }" >> $@
