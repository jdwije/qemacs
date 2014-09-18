# QEmacs Documentation

* * *

# Table of Contents

- [1. Introduction](qe-doc.html#SEC1)
- [2. Invocation](qe-doc.html#SEC2)
- [3. Common editing commands](qe-doc.html#SEC3)
  - [3.1 Concepts](qe-doc.html#SEC4)
  - [3.2 Help](qe-doc.html#SEC5)
  - [3.3 Simple commands](qe-doc.html#SEC6)
  - [3.4 Region handling](qe-doc.html#SEC7)
  - [3.5 Buffer and file handling](qe-doc.html#SEC8)
  - [3.6 Search and replace](qe-doc.html#SEC9)
  - [3.7 Command handling](qe-doc.html#SEC10)
  - [3.8 Window handling](qe-doc.html#SEC11)
  - [3.9 International](qe-doc.html#SEC12)
  - [3.10 Miscellaneous](qe-doc.html#SEC13)

- [4. Configuration file and resources](qe-doc.html#SEC14)
  - [4.1 Resource path](qe-doc.html#SEC15)
  - [4.2 Configuration file](qe-doc.html#SEC16)
  - [4.3 Plugins](qe-doc.html#SEC17)

- [5. Internationalization](qe-doc.html#SEC18)
  - [5.1 Charsets](qe-doc.html#SEC19)
  - [5.2 Input methods](qe-doc.html#SEC20)
  - [5.3 Bidirectional editing](qe-doc.html#SEC21)
  - [5.4 Unicode scripts](qe-doc.html#SEC22)

- [6. Editing Modes](qe-doc.html#SEC23)
  - [6.1 C mode](qe-doc.html#SEC24)
  - [6.2 Hexadecimal, ascii and unihex modes](qe-doc.html#SEC25)
  - [6.3 shell mode](qe-doc.html#SEC26)
  - [6.4 Dired mode](qe-doc.html#SEC27)
  - [6.5 Bufed mode](qe-doc.html#SEC28)
  - [6.6 XML mode](qe-doc.html#SEC29)
  - [6.7 Graphical HTML2/CSS mode](qe-doc.html#SEC30)
    - [6.7.1 Usage](qe-doc.html#SEC31)
    - [6.7.2 Features](qe-doc.html#SEC32)
    - [6.7.3 Known limitations](qe-doc.html#SEC33)
    - [6.7.4 CSS property support](qe-doc.html#SEC34)

  - [6.8 Graphical DocBook mode](qe-doc.html#SEC35)
  - [6.9 Image mode](qe-doc.html#SEC36)
  - [6.10 Audio/Video mode](qe-doc.html#SEC37)

- [7. Fonts](qe-doc.html#SEC38)
  - [7.1 VT100 display](qe-doc.html#SEC39)
  - [7.2 X11 display](qe-doc.html#SEC40)
  - [7.3 Internal QEmacs fonts](qe-doc.html#SEC41)

- [8. Html2png Tool](qe-doc.html#SEC42)
  - [8.1 Introduction](qe-doc.html#SEC43)
  - [8.2 Invocation](qe-doc.html#SEC44)

- [9. Developper's Guide](qe-doc.html#SEC45)
  - [9.1 Plugins](qe-doc.html#SEC46)

* * *

QEmacs Documentation

# [1. Introduction](qe-doc.html#TOC1)

QEmacs (for Quick Emacs) is a very small but powerful UNIX editor. It has features that even big editors lack :

- Full screen editor with an Emacs look and feel with all Emacs common features: multi-buffer, multi-window, command mode, universal argument, keyboard macros, config file with C like syntax, minibuffer with completion and history.
- Can edit files of hundreds of Megabytes without being slow by using a highly optimized internal representation and by mmaping the file.
- Full _Unicode_ support, including multi charset handling (8859-x, UTF8, SJIS, EUC-JP, ...) and bidirectional editing respecting the Unicode bidi algorithm. Arabic and Indic scripts handling (in progress).
- WYSIWYG _HTML/XML/CSS2_ mode graphical editing. Also supports lynx like rendering on VT100 terminals.
- WYSIWYG _DocBook_ mode based on XML/CSS2 renderer.
- C mode: coloring with immediate update. Emacs like auto-indent.
- Shell mode: colorized VT100 emulation so that your shell work exactly as you expect. Compile mode with next/prev error. 
- Input methods for most languages, including Chinese (input methods come from the Yudit editor). 
- _Hexadecimal editing_ mode with insertion and block commands. Unicode hexa editing is also supported.
- Works on any VT100 terminals without termcap. UTF8 VT100 support included with double width glyphs.
- X11 support. Support multiple proportionnal fonts at the same time (as XEmacs). X Input methods supported. Xft extension supported for anti aliased font display.
- Small! Full version (including HTML/XML/CSS2/DocBook rendering and all charsets): 200KB big. Basic version (without bidir/unicode scripts/input/X11/C/Shell/HTML/dired): 49KB.

# [2. Invocation](qe-doc.html#TOC2)

    usage: qe [-h] [-nw] [-display display] [-geometry WxH] 
              [-fs ptsize] [filename...]

<dl compact>

<dt>
<samp>`-h'</samp>
</dt>
<dd>
show help

</dd>
<dt>
<samp>`-nw'</samp>
</dt>
<dd>
force tty terminal usage

</dd>
<dt>
<samp>`-display display'</samp>
</dt>
<dd>
set X11 display to 'display'

</dd>
<dt>
<samp>`-geometry WxH'</samp>
</dt>
<dd>
set X11 display size

</dd>
<dt>
<samp>`-fs ptsize'</samp>
</dt>
<dd>
set default font size

</dd>
</dl>

When invoked as

    usage: ffplay

QEmacs goes to `dired` mode automatically so that you can browse your files easily (same as <kbd>C-x C-d</kbd> key).

# [3. Common editing commands](qe-doc.html#TOC3)

## [3.1 Concepts](qe-doc.html#TOC4)

QEmacs store file content in _buffers_. Buffers can be seen as big arrays of bytes.

An _editing mode_ tells how to display the content of a buffer and how to interact with the user to modify its content.

Multiple _Windows_ can be shown on the screen at the same time. Each windows show the content of a buffer with an editing mode. It means that you can open several windows which show the same buffer in different modes (for example, both text and hexadecimal).

Each key binding activates a _command_. You can directly execute a command by typing <kbd>M-x command RET</kbd>.

Commands can take arguments. The key binding <kbd>C-u N</kbd> where N is an optional number is used to give a numeric argument to the commands which can handle them. If the command cannot handle a numerical argument, it is simply repeated `N` times.

## [3.2 Help](qe-doc.html#TOC5)

You can press <kbd>C-h b</kbd> to have the list of all the currently active bindings, including the ones of the current editing mode.

    C-h C-h, F1 : help-for-help
    C-h b : describe-bindings
    C-h c : describe-key-briefly

## [3.3 Simple commands](qe-doc.html#TOC6)

    default : self-insert-command
    C-p, up : previous-line
    C-n, down : next-line
    C-b, left : backward-char
    C-f, right : forward-char
    M-b, C-left : backward-word
    M-f, C-right : forward-word
    M-v, prior : scroll-down
    C-v, next : scroll-up
    home, C-a : beginning-of-line
    end, C-e : end-of-line
    insert : overwrite-mode
    C-d, delete : delete-char
    backspace : backward-delete-char
    M-<, C-home : beginning-of-buffer
    M->, C-end : end-of-buffer
    C-i : tabulate
    C-q : quoted-insert
    RET : newline
    M-{ : backward-paragraph
    M-} : forward-paragraph

## [3.4 Region handling](qe-doc.html#TOC7)

    C-k : kill-line
    C-space : set-mark-command
    C-w : kill-region
    M-w : copy-region
    C-y : yank
    M-y : yank-pop
    C-x C-x : exchange-point-and-mark

## [3.5 Buffer and file handling](qe-doc.html#TOC8)

    C-x C-s : save-buffer
    C-x C-w : write-file
    C-x C-c : suspend-emacs
    C-x C-f : find-file
    C-x C-v : find-alternate-file
    C-x b : switch-to-buffer
    C-x k : kill-buffer
    C-x i : insert-file
    C-x C-q : vc-toggle-read-only
    C-x C-b : list-buffers

## [3.6 Search and replace](qe-doc.html#TOC9)

    C-s : isearch-backward
    C-r : isearch-forward
    M-% : query-replace

## [3.7 Command handling](qe-doc.html#TOC10)

    M-x : execute-extended-command
    C-u : universal-argument
    C-g : abort
    C-x u, C-_ : undo
    C-x ( : start-kbd-macro
    C-x ) : end-kbd-macro
    C-x e : call-last-kbd-macro

## [3.8 Window handling](qe-doc.html#TOC11)

    C-x o : other-window
    C-x 0 : delete-window
    C-x 1 : delete-other-windows
    C-x 2 : split-window-vertically
    C-x 3 : split-window-horizontally
    C-x f : toggle-full-screen

## [3.9 International](qe-doc.html#TOC12)

    C-x RET f : set-buffer-file-coding-system
    C-x RET b : toggle-bidir
    C-x RET C-\ : set-input-method
    C-\ : switch-input-method

## [3.10 Miscellaneous](qe-doc.html#TOC13)

    C-l : refresh
    M-g : goto-line
    M-q : fill-paragraph
    C-x RET l : toggle-line-numbers
    C-x RET t : truncate-lines
    C-x RET w : word-wrap
    C-x C-e : compile
    C-x C-p : previous-error
    C-x C-n : next-error
    C-x C-d : dired

# [4. Configuration file and resources](qe-doc.html#TOC14)

## [4.1 Resource path](qe-doc.html#TOC15)

All resources and configuration files are looked in the following paths:<tt>`/usr/share/qe:/usr/local/share/qe:/usr/lib/qe:/usr/local/lib/qe:~/.qe'</tt>

## [4.2 Configuration file](qe-doc.html#TOC16)

QEmacs tries to load a configuration file in <tt>`~/.qe/config'</tt>. Each line of the configuration file is a QEmacs command with a C like syntax ('-' in command name can be replaced by '\_').

Read the example file <tt>`config.eg'</tt> to have some examples.

The following commands are useful:

<dl compact>

<dt>
<code>global_set_key(key, command)</code>
</dt>
<dd>
Set a global key binding to a command.

</dd>
<dt>
<code>set_display_size(width, height)</code>
</dt>
<dd>
(X11) Set the window size, in character cells.

</dd>
<dt>
<code>set_system_font(family, system_fonts)</code>
</dt>
<dd>
(X11) Maps a system font to a QEmacs font family. Multiple fonts can be
given as fallback (See section <a href="qe-doc.html#SEC38">7. Fonts</a>).

</dd>
<dt>
<code>set_style(stylename, css_property, css_value)</code>
</dt>
<dd>
Set a colorization style (see <tt>`qestyle.h'</tt> and <tt>`config.eg'</tt> for
common style names)

</dd>
</dl>
## [4.3 Plugins](qe-doc.html#TOC17)

Any <tt>`.so'</tt> file found in the qemacs resource paths is considered as a _plugin_. It is a piece of code containing new features for qemacs.

Currently, no plugins are compiled in, but you can look at the<tt>`plugin-example/'</tt> directory to learn how to make one.

Most QEmacs object files can in fact be compiled either as a plugin or be statically linked in qemacs. The plugin system is strongly inspirated from the Linux Kernel 2.4 module system.

# [5. Internationalization](qe-doc.html#TOC18)

## [5.1 Charsets](qe-doc.html#TOC19)

QEmacs supports many common charsets including UTF8, shift JIS and EUC-JP. A charset can be selected for each buffer with <kbd>C-x RET f</kbd>(`set-buffer-file-coding-system`).

Currently, QEmacs automatically detects the UTF8 encoding.

Note that unlike in other editors, changing the charset of a buffer does not modify its content: buffers always contain bytes, and the charset is only used when the buffer content may be converted to characters, for example to display it on screen.

You can use the UniHex editing mode (<kbd>M-x unihex-mode</kbd>) to see the Unicode values of each character in your file with the associated byte offset.

The command `convert-buffer-file-coding-system` can be used to convert the buffer _content_ to another charset.

## [5.2 Input methods](qe-doc.html#TOC20)

The current input method can be changed with <kbd>C-x RET \</kbd>(`set-input-method`). You can switch between this input method and the default one with 'C-\'.

The input methods are currently stored in the resource file <tt>`kmaps'</tt>. They are extracted from the _Yudit_ editor keyboard maps.

## [5.3 Bidirectional editing](qe-doc.html#TOC21)

QEmacs fully supports the Unicode bidi algorithm.

By default, in text editing mode, qemacs is not in bidirectionnal mode (it may change soon). You can use 'C-x RET b' to toogle between bidi and normal editing modes.

In HTML editing mode, bidi is always activated and all the CSS2 bidi properties are supported.

## [5.4 Unicode scripts](qe-doc.html#TOC22)

Currently, QEmacs fully supports Arabic shapping. Devanagari shaping is on the way.

The resource file <tt>`ligatures'</tt> contains all the standard Unicode rules to handle character modifiers such as accents. It means that even if your font does not support the Unicode character modifiers, QEmacs will do its best to handle them.

# [6. Editing Modes](qe-doc.html#TOC23)

## [6.1 C mode](qe-doc.html#TOC24)

This mode is currently activated by <samp>`M-x c-mode'</samp>. It is activated automatically when a C file is loaded.

## [6.2 Hexadecimal, ascii and unihex modes](qe-doc.html#TOC25)

Unlike other editors, QEmacs has powerful hexadecimal editing modes: all common commands are working these modes, including the block commands.

The hexadecimal mode (<kbd>M-x hex-mode</kbd>) shows both the hexa decimal and ascii (bytes) values. You can toggle between the hexa and ascii columns with 'TAB'.

The ascii mode (<kbd>M-x ascii-mode</kbd>) only shows the ascii column.

The unihex mode (<kbd>M-x unihex-mode</kbd>) shows both the unicode and glyph associated to each _character_ of the buffer by using the current buffer charset.

You can change the line width in these modes with 'C-left' and 'C-right'.

## [6.3 shell mode](qe-doc.html#TOC26)

You can activate it with <kbd>M-x shell</kbd>. Unlike other editors, a very complete colorized VT100 emulation is done [it means you can launch qemacs in the qemacs shell :-)].

By default, _interactive mode_ is selected. It means that most keys you type are transmitted to the shell. This way, you can use the shell completion and editing functions. By pressing <kbd>C-o</kbd>, you toggle between interactive and editing mode. In editing mode, you can editing the shell buffer as any other buffer.

## [6.4 Dired mode](qe-doc.html#TOC27)

You can activate it with <kbd>C-x C-d</kbd>. You can open the selected directory with <kbd>RET</kbd> or <kbd>right</kbd>. <kbd>left</kbd> is used to go to the parent directory. The current selected is opened in the right window.

## [6.5 Bufed mode](qe-doc.html#TOC28)

You can activate it with <kbd>C-x C-b</kbd>. You can select with <kbd>RET</kbd> or<kbd>right</kbd> the current buffer.

## [6.6 XML mode](qe-doc.html#TOC29)

This mode is currently activated by <kbd>M-x xml-mode</kbd>. It is activated automatically when an XML file is loaded.

Currently, only specific XML colorization is done in this mode. Javascript (in SCRIPT tags) is colored as in C mode. CSS Style sheets (in STYLE tags) are colorized with a specific color.

## [6.7 Graphical HTML2/CSS mode](qe-doc.html#TOC30)

### [6.7.1 Usage](qe-doc.html#TOC31)

This mode is currently activated by <kbd>M-x html-mode</kbd>. It is activated automatically when an HTML file is loaded.

### [6.7.2 Features](qe-doc.html#TOC32)

The XML/HTML/CSS2 renderer has the following features:

- The parse errors are written in buffer '\*xml-error\*'.
- Strict XML parser or relaxed mode for HTML pages.
- Letter case can be ignored or strictly respected.
- Integrated HTML to CSS2 converter so that the renderer do not depend on HTML quirks.
- Quite complete CSS2 support (including generated content and counters).
- Full Bidirectionnal Unicode support.
- Table support with both 'fixed' and 'auto' layout algorithms.
- 'tty' and 'screen' CSS2 medias are supported.

### [6.7.3 Known limitations](qe-doc.html#TOC33)

- Cannot load external resources (e.g. style sheets) from other files.
- No image handling (only a rectangle with 'ALT' name is drawn).
- No javascript.
- No frames.

### [6.7.4 CSS property support](qe-doc.html#TOC34)

The following properties are partially (see comments) or totally supported:

- display: The value 'inline-block' is a QEmacs extension.
- color
- background-color
- white-space: The value 'prewrap' is a QEmacs extension.
- direction
- float
- font-family
- font-style
- font-weight
- font-size
- text-decoration
- text-align
- width
- height
- unicode-bidi
- border-width
- border-left-width
- border-top-width
- border-right-width
- border-bottom-width
- border-color
- border-left-color
- border-top-color
- border-right-color
- border-bottom-color
- border-style
- border-left-style
- border-top-style
- border-right-style
- border-bottom-style
- border
- border-left
- border-top
- border-right
- border-bottom
- padding
- padding-left
- padding-top
- padding-right
- padding-bottom
- margin
- margin-left
- margin-top
- margin-right
- margin-bottom
- clear
- overflow
- visibility
- table-layout
- vertical-align
- border-collapse
- border-spacing
- border-spacing-horizontal
- border-spacing-vertical
- line-height
- content
- caption-side
- marker-offset
- list-style-type
- column-span: QEmacs extension
- row-span: QEmacs extension
- content-alt: QEmacs extension. Same behavior as property 'content' but used for images
- list-style-position
- counter-reset
- counter-increment
- bidi-mode: QEmacs extension: use lower/upper case to test bidi algorithm
- position: <samp>`fixed'</samp> is not supported. Only 'block' boxes are positionned
- top
- bottom
- left
- right

The following properties are completely unsupported:

- background
- background-attachment
- background-image
- background-position
- background-repeat
- clip
- cursor
- empty-cells
- font
- font-size-adjust
- font-stretch
- font-variant
- letter-spacing
- list-style
- list-style-image
- max-height
- max-width
- min-height
- min-width
- outline
- outline-color
- outline-style
- outline-width
- quotes
- text-indent
- text-shadow
- text-transform
- word-spacing
- z-index
- marks
- page
- page-break-after
- page-break-before
- page-break-inside
- size
- orphans
- widows
- azimuth
- cue
- cue-after
- cue-before
- elevation
- pause
- pause-after
- pause-before
- pitch
- pitch-range
- pitch-during
- richness
- speak
- speak-header
- speak-punctuation
- speak-rate
- stress
- voice-family
- volume

## [6.8 Graphical DocBook mode](qe-doc.html#TOC35)

This mode simply uses a different default style sheet from the HTML/CSS2 mode. It is activated by <samp>`M-x docbook-mode'</samp>.

## [6.9 Image mode](qe-doc.html#TOC36)

When compiling qemacs with FFmpeg support ( [http://ffmpeg.org](http://ffmpeg.org)), images can be viewed. The current implementation handles PNM, PAM, PNG, JPEG and GIF images (animated GIF images are handled as video data). <kbd>C-x C-d</kbd> can be used to have an interactive file viewer.

Available commands:

<dl compact>

<dt>
<kbd>t</kbd>
</dt>
<dd>
(<samp>`M-x image-rotate'</samp>) Rotate right image by 90 degrees.
</dd>
<dt>
<kbd>f</kbd>
</dt>
<dd>
(<samp>`M-x toggle-full-screen'</samp>) Toggle full screen mode
</dd>
<dt>
<kbd>c</kbd>
</dt>
<dd>
(<samp>`M-x image-convert'</samp>) Change the pixel format of the image (press tab
to have a complete list). The data loss implied by the pixel format
change is displayed.
</dd>
<dt>
<kbd>b</kbd>
</dt>
<dd>
(<samp>`M-x image-set-background-color'</samp>) Set the image background
color. The background is only visible if the image contains transparent
pixels. The <samp>`transparent'</samp> color displayed a <samp>`gimp'</samp> like grid.
</dd>
</dl>

Status information:

- The image resolution is displayed as <samp>`NxM'</samp>.
- The FFmpeg pixel format is displayed.
- <samp>`I'</samp> is displayed is the image is interleaved.
- <samp>`T'</samp> is displayed if the image contains transparent pixels. <samp>`A'</samp> is displayed if the image contains semi-transparent pixels.

## [6.10 Audio/Video mode](qe-doc.html#TOC37)

When compiling qemacs with FFmpeg support ( [http://ffmpeg.org](http://ffmpeg.org)), video and audio files can be viewed. The X11 Xvideo extension is used if available for faster YUV rendering. <kbd>C-x C-d</kbd> can be used to have an interactive file viewer.

Audio only files are also rendered. The waveform is displayed at the same time.

No editing commands will be supported in that mode. Saving is currently not possible.

Available commands:

<dl compact>

<dt>
<kbd>SPC</kbd>
</dt>
<dd>
</dd>
<dt>
<kbd>p</kbd>
</dt>
<dd>
Pause/Resume
</dd>
<dt>
<kbd>f</kbd>
</dt>
<dd>
(<samp>`M-x toggle-full-screen'</samp>) Toggle full screen mode
</dd>
<dt>
<kbd>v</kbd>
</dt>
<dd>
(<samp>`M-x av-cycle-video'</samp>) Cycle through available video channels.
</dd>
<dt>
<kbd>a</kbd>
</dt>
<dd>
(<samp>`M-x av-cycle-audio'</samp>) Cycle through available audio channels.
</dd>
</dl>
# [7. Fonts](qe-doc.html#TOC38)

## [7.1 VT100 display](qe-doc.html#TOC39)

In order to display Unicode characters, you must have a recent xterm from XFree version greater than 4.0.1.

As a short test, you can launch xterm with the following options to select UTF8 charset and a unicode fixed X11 font:

    xterm -u8 -fn -misc-fixed-medium-r-normal--18-120-100-100-c-90-iso10646-1

Then look at the qemacs TestPage in VT100 mode:

    qe -nw tests/TestPage.txt

If you are using latin scripts, you can use any fixed font in any terminal. Otherwise, if you use ideograms or other non latin scripts, you must configure your terminal emulator (usually xterm) to accept 'double width' fonts. It means that some characters, such as ideograms, are meant to occupy two char cells instead of one. QEmacs knows that and does the text alyout accordingly.

The font _Unifont_ is currently the best font for xterm. It is usually included in the linux distributions. You can find it at [http://czyborra.com/unifont/](http://czyborra.com/unifont/).

## [7.2 X11 display](qe-doc.html#TOC40)

QEmacs knows three basic font families:

- <samp>`sans'</samp> for sans serif fonts.
- <samp>`serif'</samp> for serif fonts.
- <samp>`fixed'</samp> for fixed or monospace fonts.

QEmacs maps these three families to system fonts. The default mapping is: <samp>`helvetica'</samp> for sans, <samp>`Times'</samp> for serif and <samp>`fixed'</samp>for fixed.

For each family, you can specify any number of _fallback fonts_ that QEmacs can use if the requested glyph is not found in the current font. Currently, the font <samp>`unifont'</samp> is used as fallback in all cases.

You can use the command `set-system-font(family, fonts)` to change the default qemacs mapping. `family` is `sans`, `serif`or `fixed`, and `fonts` is a comma separated list of system fonts which are used as principal font and fallback fonts.

## [7.3 Internal QEmacs fonts](qe-doc.html#TOC41)

In the tool <samp>`html2png'</samp>, QEmacs uses internal fonts which are the<samp>`Times'</samp>, <samp>`Helvetica'</samp> and <samp>`Unifont'</samp> supplied in X11. They are highly compressed in the _FBF_ font format.

# [8. Html2png Tool](qe-doc.html#TOC42)

## [8.1 Introduction](qe-doc.html#TOC43)

Html2png is a standalone HTML/XML/CSS2 renderer based on the QEmacs internal renderer. It takes an HTML or XHTML file as input and produce a PNG image file containing the graphical rendering of the page. It is meant to be a test tool for the renderer. It can also be used as a XML/HTML validator since all parse errors are logged on the standard output.

Unlike other HTML renderers, HTML2PNG do not have any dependency on the operating system or the graphical interface. It uses its own fonts (which are embedded in the executable), its own widgets and its own charset tables.

By using the highly compressed FBF font format, the Times, Helvetica and Unifont fonts are embedded in the executable. It means that HTML2PNG can view documents in any languages, including Arabic, Hebrew, Japanese and Hangul.

## [8.2 Invocation](qe-doc.html#TOC44)

    usage: html2png [-h] [-x] [-w width] [-o outfile] [-f charset] infile

<dl compact>

<dt>
<samp>`-h'</samp>
</dt>
<dd>
display the help
</dd>
<dt>
<samp>`-x'</samp>
</dt>
<dd>
use strict XML parser (xhtml type parsing)
</dd>
<dt>
<samp>`-w width'</samp>
</dt>
<dd>
set the image width (default=640)
</dd>
<dt>
<samp>`-f charset'</samp>
</dt>
<dd>
set the default charset (default='8859-1'). Use -f ? to list supported charsets.
</dd>
<dt>
<samp>`-o outfile'</samp>
</dt>
<dd>
set the output filename (default='a.png')
</dd>
</dl>
# [9. Developper's Guide](qe-doc.html#TOC45)

## [9.1 Plugins](qe-doc.html#TOC46)

You can use the example in <tt>`plugin-example/'</tt> to develop dynamically linked qemacs plugins (aka modules).

Plugins can add any dynamic resource qemacs supports (modes, key bindings, ...). A plugin can be either statically linked or dynamically linked. Most of qemacs features are in fact statically linked plugins.

* * *


