include config.mak

# from configure
#CONFIG_TINY=y
#CONFIG_X11=y
#CONFIG_XFT=y
#CONFIG_WIN32=y
#CONFIG_PNG_OUTPUT=y
#CONFIG_FFMPEG=y
#CONFIG_HTML=y
#CONFIG_DLL=y
#CONFIG_UNICODE_JOIN=y
#CONFIG_ALL_KMAPS=y

CFLAGS:=-fno-strict-aliasing -Wall -g $(CFLAGS)
# use it for gcc >= 4.7.0
#CFLAGS+=-Wno-unused-but-set-variable
#CFLAGS+=-Werror
ifdef TARGET_GPROF
CFLAGS+= -p
LDFLAGS+= -p
endif
ifdef TARGET_ARCH_X86
#CFLAGS+=-fomit-frame-pointer
ifeq ($(GCC_MAJOR),2)
CFLAGS+=-m386 -malign-functions=0
else
CFLAGS+=-march=i386 -falign-functions=0
endif
endif
DEFINES=-DHAVE_QE_CONFIG_H

########################################################
# do not modify after this

ifdef CONFIG_WIN32
CONFIG_ALL_KMAPS=
CONFIG_X11=
CONFIG_DLL=
EXE=.exe
endif

ifdef CONFIG_PNG_OUTPUT
HTMLTOPPM_LIBS+= -lpng
endif

ifdef CONFIG_DLL
LIBS+=-ldl
# export some qemacs symbols
# XXX: These linker flags cause compile errors on OSX, specifically the -E opt.
#      removing does not seem to break compilation in Linux...
# LDFLAGS+=-Wl,-E
endif
LIBS+=-lm

TARGETS+=qe$(EXE) qe-doc.html

OBJS=qe.o charset.o buffer.o \
     input.o unicode_join.o display.o util.o hex.o list.o cutils.o
ifndef CONFIG_WIN32
OBJS+= unix.o tty.o 
endif

OBJS+= unihex.o clang.o latex-mode.o xml.o bufed.o
ifndef CONFIG_WIN32
OBJS+= shell.o dired.o 
endif

ifdef CONFIG_WIN32
OBJS+= win32.o
LIBS+= -lgdi32
endif

# currently not used in qemacs
ifdef CONFIG_CFB
OBJS+= libfbf.o fbfrender.o cfb.o fbffonts.o
endif


ifdef CONFIG_OSX
CONFIG_X11=
OBJS+= osx.o
# XXX: no need to include x11 lib on osx anymore I /opt/X11/include 
LDFLAGS+=-framework Cocoa
LIBS+=-lobjc
endif

ifdef CONFIG_X11
OBJS+= x11.o
ifdef CONFIG_XRENDER
LIBS+=-lXrender
endif
ifdef CONFIG_XV
LIBS+=-lXv
endif
LIBS+= -L/usr/X11R6/lib -lXext -lX11
endif

ifdef CONFIG_HTML
CFLAGS+=-I./libqhtml
DEP_LIBS+=libqhtml/libqhtml.a 
LIBS+=-L./libqhtml -lqhtml
OBJS+=html.o docbook.o
ifndef CONFIG_WIN32
TARGETS+=html2png
endif
endif

ifdef CONFIG_UNICODE_JOIN
OBJS+= charsetmore.o charset_table.o arabic.o indic.o qfribidi.o unihex.o
endif

ifdef CONFIG_FFMPEG
OBJS+= video.o image.o
DEP_LIBS+=$(FFMPEG_LIBDIR)/libavcodec/libavcodec.a $(FFMPEG_LIBDIR)/libavformat/libavformat.a
LIBS+=  -L$(FFMPEG_LIBDIR)/libavcodec -L$(FFMPEG_LIBDIR)/libavformat -lavformat -lavcodec -lz -lpthread
DEFINES+= -I$(FFMPEG_SRCDIR)/libavcodec -I$(FFMPEG_SRCDIR)/libavformat
TARGETS+=ffplay
endif

# must be the last object
OBJS+= qeend.o

all: lib $(TARGETS)

lib:
	make -C libqhtml all

qe_g: $(OBJS) $(DEP_LIBS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

qe$(EXE): qe_g
	cp $< $@
	$(STRIP) $@
	@ls -l $@

ffplay: qe$(EXE)
	ln -sf $< $@

qe.o: qe.c qe.h qfribidi.h

charset.o: charset.c qe.h

buffer.o: buffer.c qe.h

tty.o: tty.c qe.h

qfribidi.o: qfribidi.c qfribidi.h

cfb.o: cfb.c cfb.h fbfrender.h

fbfrender.o: fbfrender.c fbfrender.h libfbf.h

html2png.o: html2png.c qe.h

%.o : %.c
	$(CC) $(DEFINES) $(CFLAGS) -o $@ -c $<

%.o : %.m
	$(CC) $(DEFINES) $(CFLAGS) -o $@ -c $<

clean:
	make -C libqhtml clean
	rm -f *.o *~ TAGS gmon.out core \
           qe qe_g qe.exe qfribidi kmaptoqe ligtoqe \
           html2png fbftoqe fbffonts.c

distclean: clean
	rm -f config.h config.mak

install: qe qe.1 kmaps ligatures html2png
	install -m 755 qe $(prefix)/bin/qemacs
	ln -sf qemacs $(prefix)/bin/qe
ifdef CONFIG_FFMPEG
	ln -sf qemacs $(prefix)/bin/ffplay
endif
	mkdir -p $(prefix)/share/qe
	install kmaps ligatures $(prefix)/share/qe
	install qe.1 $(prefix)/man/man1
	install -m 755 -s html2png $(prefix)/bin

TAGS: force
	etags *.[ch]

force:

#
# tar archive for distribution
#

FILES=Changelog COPYING README TODO qe.1 config.eg \
Makefile qe.tcc qemacs.spec \
hex.c charset.c qe.c qe.h tty.c \
html.c indic.c unicode_join.c input.c qeconfig.h \
qeend.c unihex.c arabic.c kmaptoqe.c util.c \
bufed.c qestyles.h x11.c buffer.c ligtoqe.c \
qfribidi.c clang.c latex-mode.c xml.c dired.c list.c qfribidi.h html2png.c \
charsetmore.c charset_table.c cptoqe.c \
libfbf.c fbfrender.c cfb.c fbftoqe.c libfbf.h fbfrender.h cfb.h \
display.c osx.h osx.m display.h mpeg.c shell.c \
docbook.c unifont.lig kmaps xterm-146-dw-patch \
ligatures qe-doc.texi qe-doc.html \
tests/HELLO.txt tests/TestPage.txt tests/test-hebrew \
tests/test-capital-rtl tests/test-capital-rtl.ref \
tests/testbidi.html \
plugin-example/Makefile  plugin-example/my_plugin.c \
image.c video.c win32.c configure VERSION \
cutils.c cutils.h unix.c

# qhtml library
FILES+=libqhtml/Makefile libqhtml/css.c libqhtml/cssid.h \
libqhtml/cssparse.c libqhtml/xmlparse.c libqhtml/htmlent.h \
libqhtml/css.h libqhtml/csstoqe.c \
libqhtml/docbook.css libqhtml/html.css 

# fonts
FILES+=fonts/fixed10.fbf  fonts/fixed12.fbf  fonts/fixed13.fbf  fonts/fixed14.fbf \
fonts/helv10.fbf   fonts/helv12.fbf   fonts/helv14.fbf   fonts/helv18.fbf \
fonts/helv24.fbf   fonts/helv8.fbf    fonts/times10.fbf  fonts/times12.fbf \
fonts/times14.fbf  fonts/times18.fbf  fonts/times24.fbf  fonts/times8.fbf \
fonts/unifont.fbf

FILE=qemacs-$(shell cat VERSION)

tar:
	rm -rf /tmp/$(FILE)
	mkdir -p /tmp/$(FILE)
	cp -r . /tmp/$(FILE)
	( cd /tmp ; tar zcvf $(FILE).tar.gz $(FILE) )
	rm -rf /tmp/$(FILE)

#
# Test for bidir algorithm
#
qfribidi: qfribidi.c
	$(HOST_CC) $(CFLAGS) -DTEST -o $@ $<

#
# build ligature table
#
ligtoqe: ligtoqe.c
	$(HOST_CC) $(CFLAGS) -o $@ $<

ifdef BUILD_ALL
ligatures: unifont.lig ligtoqe
	./ligtoqe unifont.lig $@
endif

#
# Key maps build (Only useful if you want to build your own maps from yudit maps)
#
KMAPS=Arabic.kmap ArmenianEast.kmap ArmenianWest.kmap Chinese-CJ.kmap \
      Cyrillic.kmap Czech.kmap DE-RU.kmap Danish.kmap Dutch.kmap \
      Esperanto.kmap Ethiopic.kmap French.kmap Georgian.kmap German.kmap \
      Greek.kmap GreekMono.kmap Guarani.kmap Hebrew.kmap HebrewIsraeli.kmap \
      Hungarian.kmap \
      KOI8_R.kmap Kana.kmap Lithuanian.kmap Mnemonic.kmap Polish.kmap \
      Russian.kmap SGML.kmap TeX.kmap Troff.kmap VNtelex.kmap \
      Vietnamese.kmap XKB_iso8859-4.kmap
#     Hangul.kmap Hangul2.kmap Hangul3.kmap Unicode2.kmap 
KMAPS_DIR=$(prefix)/share/yudit/data
KMAPS:=$(addprefix $(KMAPS_DIR)/, $(KMAPS))

kmaptoqe: kmaptoqe.c
	$(HOST_CC) $(CFLAGS) -o $@ $<

ifdef BUILD_ALL
kmaps: kmaptoqe $(KMAPS)
	./kmaptoqe $@ $(KMAPS)
endif

#
# Code pages (only useful to add your own code pages)
#
CP=8859_2.cp  cp1125.cp  cp737.cp  koi8_r.cp \
   8859_4.cp  cp1250.cp  cp850.cp  koi8_u.cp    viscii.cp\
   8859_13.cp  8859_5.cp  cp1251.cp  cp852.cp  mac_lat2.cp\
   8859_15.cp  8859_7.cp  cp1257.cp  cp866.cp  macroman.cp\
   8859_16.cp  8859_9.cp  cp437.cp   kamen.cp  tcvn5712.cp \
   JIS0208.TXT JIS0212.TXT
CP:=$(addprefix cp/,$(CP))

cptoqe: cptoqe.c
	$(HOST_CC) $(CFLAGS) -o $@ $<

ifdef BUILD_ALL
charset_table.c: cptoqe $(CP)
	./cptoqe $(CP) > $@
endif

#
# fonts (only needed for html2png)
#
FONTS=fixed10.fbf fixed12.fbf fixed13.fbf fixed14.fbf\
helv8.fbf helv10.fbf helv12.fbf helv14.fbf helv18.fbf helv24.fbf\
times8.fbf times10.fbf times12.fbf times14.fbf times18.fbf times24.fbf\
unifont.fbf
FONTS:=$(addprefix fonts/,$(FONTS))

fbftoqe: fbftoqe.c
	$(CC) $(CFLAGS) -o $@ $<

fbffonts.c: fbftoqe $(FONTS)
	./fbftoqe $(FONTS) > $@

#
# html2png tool (XML/HTML/CSS2 renderer test tool)
#
OBJS=util.o cutils.o \
     arabic.o indic.o qfribidi.o \
     display.o unicode_join.o charset.o charsetmore.o charset_table.o \
     libfbf.o fbfrender.o cfb.o fbffonts.o

html2png: html2png.o $(OBJS) libqhtml/libqhtml.a
	$(HOST_CC) $(LDFLAGS) -o $@ html2png.o $(OBJS) \
                   -L./libqhtml -lqhtml $(HTMLTOPPM_LIBS)

# autotest target
test:
	make -C tests test

# documentation
qe-doc.html: qe-doc.texi
	texi2html -monolithic -number $<
