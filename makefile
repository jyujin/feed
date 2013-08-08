BINARIES:=bin/feedd bin/feed
INCLUDES:=$(wildcard include/feed/*.h)
INSTALLTARGETS:=$(BINARIES) $(INCLUDES) include/feed/data-feed.h
TARGETS:=$(BINARIES) include/feed/data-feed.h
DESTDIR:=/usr/local

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

install: $(addprefix $(DESTDIR)/,$(INSTALLTARGETS))

uninstall:
	rm -f $(addprefix $(DESTDIR)/,$(INSTALLTARGETS))

$(DESTDIR)/%: %
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
