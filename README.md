QEmacs
===

This is a development fork of [QEmacs](http://www.bellard.org/qemacs/).

[![Build Status](https://travis-ci.org/jdwije/qemacs.svg?branch=osx-driver)](https://travis-ci.org/jdwije/qemacs)

1. [ ] Bug fixing and stabilizing the software
2. [ ] Getting cross platform compilation working again and port to OSX
  - [x] OSX
  - [x] Linux
  - [ ] Windows
3. [ ] A native osx driver

## Compiling

1. If you want image, audio and video support, download FFmpeg at
   http://ffmpeg.org. Compile, then install it in the qemacs/ directory (it should
   be in qemacs/ffmpeg). 
2. Launch the configure tool './configure'. You can look at the
   possible options by typing './configure --help'.
3. Type 'make' to compile qemacs and its associated tools.
4. Type 'make install' as root to install it in /usr/local

## Documentation

See [qe-doc.md](http://github.com/jdwije/qemacs/blob/master/qe-doc.md) or alternatively read qe-doc.html or qe-doc.texi for the official docs.

## Licensing

QEmacs is released under the GNU Lesser General Public License, please read the accompanying LICENSE.md file.

Copyright holder [Fabrice Bellard](http://www.bellard.org).
