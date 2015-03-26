qemacs 0.3.3 [jdog fork]
===

QEmacs *{Quick Emacs}* is a fast, lightweight emacs built by Fabrice Bellard. This is my fork of the project, the goals I am working toward are:

1. [ ] Bug fixing and stabilising the software
2. [ ] Getting cross platform compilation working again
  - [x] OSX
  - [ ] Linux
  - [ ] Windows
3. [ ] Adding a ruby extension system to compliment the existing C based system
4. [ ] Updating the in-built html/css renderer to work with HTML5 and CSS3
5. [ ] Maybe updgrade said renderer into an actual browser


## Compiling

1. If you want image, audio and video support, download FFmpeg at
   http://ffmpeg.org. Compile, then install it in the qemacs/ directory (it should
   be in qemacs/ffmpeg). 
2. Launch the configure tool './configure'. You can look at the
   possible options by typing './configure --help'.
3. Type 'make' to compile qemacs and its associated tools.
4. Type 'make install' as root to install it in /usr/local

## Documentation

See [qe-doc.md](http://github.com/jdwije/qemacs/blob/master/qe-doc.md). Alernative read qe-doc.html or qe-doc.texi.

## Licensing

QEmacs is released under the GNU Lesser General Public License, please read the accompanying LICENSE.md file.

Copyright holder [Fabrice Bellard](http://www.bellard.org).
