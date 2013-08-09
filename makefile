BINARIES:=bin/feedd bin/feed
INCLUDES:=$(wildcard include/feed/*.h)
MANPAGES:=$(addprefix share/man/man1/,$(notdir $(wildcard src/*.1)))
INSTALLTARGETS:=$(BINARIES) $(INCLUDES) $(MANPAGES) include/feed/data-feed.h
TARGETS:=$(BINARIES) include/feed/data-feed.h
DESTDIR:=
PREFIX:=/usr/local
DEST:=$(DESTDIR)$(PREFIX)
VERSION:=1

# programmes
SQLITE3:=sqlite3
INSTALL:=install
CXX:=clang++
CC:=clang
PKGCONFIG:=pkg-config
INSTALL:=install

# paths, etc
INCLUDES:=include
LIBRARIES:=sqlite3 libcurl libxml-2.0

# boost libraries
BOOSTLIBDIR:=
BOOSTLIBRARIES:=regex

# flags
CCFLAGS:=$(addprefix -I,$(INCLUDES)) $(addprefix -I,$(BOOSTLIBDIR))
PCCFLAGS:=$(shell $(PKGCONFIG) --cflags $(LIBRARIES))
PCLDFLAGS:=$(shell $(PKGCONFIG) --libs $(LIBRARIES)) $(addprefix -lboost_,$(BOOSTLIBRARIES))
CXXFLAGS:=-O3
CFLAGS:=
LDFLAGS:=
CXXR:=$(CXX) $(CCFLAGS) $(PCCFLAGS) $(CXXFLAGS) $(LDFLAGS) $(PCLDFLAGS)
CR:=$(CC) $(CCFLAGS) $(PCCFLAGS) $(CFLAGS) $(LDFLAGS) $(PCLDFLAGS)

# meta rules
all: $(TARGETS)

.SECONDARY:

clean:
	rm -f data.feed* $(TARGETS)

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

bin/.volatile:
	mkdir $(dir $@); true
	touch $@

bin/%: src/%.c++ bin/.volatile include/feed/data-feed.h
	$(CXXR) $(CXXFLAGS) $< -o $@

include/feed/data-%.h: src/%.sql
	echo '/* autogenerated data file, based on $< */' > $@
	echo "namespace feed { namespace data { static const char $*[] = \"$$(sed -e ':a;N;$$!ba;s/\n/\\\\n/g' -e 's/"/\\"/g' $<)\"; } }" >> $@
