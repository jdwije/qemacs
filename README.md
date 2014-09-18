----------------------------------------------------------
                     Compiling
----------------------------------------------------------

* If you want image, audio and video support, download FFmpeg at
  http://ffmpeg.org. Compile, then install it in the qemacs/ directory (it should
  be in qemacs/ffmpeg). 

* Launch the configure tool './configure'. You can look at the
  possible options by typing './configure --help'.

* Type 'make' to compile qemacs and its associated tools.

* type 'make install' as root to install it in /usr/local.

----------------------------------------------------------
                     Documentation
----------------------------------------------------------

Read the file qe-doc.html.

----------------------------------------------------------
                     Licensing
----------------------------------------------------------

QEmacs is released under the GNU Lesser General Public License (read
the accompagning COPYING file).

Fabrice Bellard.


osx config

./configure --with-ffmpegdir=/usr/local/cellar/ffmpeg/2.2.3/include --with-ffmpeglibdir=/usr/local/cellar/ffmpeg/2.2.3/lib
