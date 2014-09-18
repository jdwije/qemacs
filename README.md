qemacs 0.3.3 [jdog fork]
---

QEmacs *{Quick Emacs}* is a fast, lightweight emacs originally built by Fabrice Bellard. The **jdog fork** is a version of qemacs I am working on, it's major goals are the following:

- full HTML/CSS/JS browser rendering
- a first class JS extension system
- minimal code base premised on building from scratch

## Compiling

1. If you want image, audio and video support, download FFmpeg at
   http://ffmpeg.org. Compile, then install it in the qemacs/ directory (it should
   be in qemacs/ffmpeg). 
2. Launch the configure tool './configure'. You can look at the
   possible options by typing './configure --help'.
3. Type 'make' to compile qemacs and its associated tools.
4. Type 'make install' as root to install it in /usr/local.

## Documentation

See [qe-doc.md](http://github.com/jdwije/qemacs/blob/master/qe-doc.md). Alernative read qe-doc.html or qe-doc.texi.

## Licensing

QEmacs is released under the GNU Lesser General Public License, please read the accompanying LICENSE.md file.

Copyright holder [Fabrice Bellard](http://www.bellard.org).
