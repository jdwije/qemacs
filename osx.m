/*
 * OSX Driver for QEMacs
 * Copyright (c) 2015 Jason Wijegooneratne
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import <Cocoa/Cocoa.h>

#include "qe.h"
#include "osx.h"

static QEDisplay osx_dpy;


static int osx_probe(void);
static int osx_init(QEditScreen *s, int w, int h);
static void osx_close(QEditScreen *s);
static void osx_resize(QEditScreen *s, int w, int h);
static void osx_fill_rectangle(QEditScreen *s, int x1, int y1, int w, int h, QEColor color);
static QEFont *osx_open_font(QEditScreen *s, int style, int size);
static void osx_draw_text(QEditScreen *s, QEFont *font, int x, int y, const unsigned int *str, int len, QEColor color);
static void osx_fill_rectangle(QEditScreen *s,
				 int x1, int y1, int w, int h, QEColor color);
static QEFont *osx_open_font(QEditScreen *s, int style, int size);
static void osx_close_font(QEditScreen *s, QEFont *font);
static void osx_text_metrics(QEditScreen *s, QEFont *font, 
			       QECharMetrics *metrics,
			       const unsigned int *str, int len);
static void osx_draw_text(QEditScreen *s, QEFont *font,
			    int x1, int y, const unsigned int *str, int len,
			    QEColor color);
static void osx_set_clip(QEditScreen *s,
			   int x, int y, int w, int h);
static void osx_flush(QEditScreen *s);
static void osx_full_screen(QEditScreen *s, int full_screen);
static void osx_selection_activate(QEditScreen *s);
static void osx_selection_request(QEditScreen *s);
static int osx_is_user_input_pending(QEditScreen *s);
static void osx_handle_event(void *opaque);
static void osx_bmp_free(QEditScreen *s, QEBitmap *b);
static void osx_bmp_draw(QEditScreen *s, QEBitmap *b, 
			   int dst_x, int dst_y, int dst_w, int dst_h, 
			   int offset_x, int offset_y, int flags);
static void osx_bmp_lock(QEditScreen *s, QEBitmap *b, QEPicture *pict,
			   int x1, int y1, int w1, int h1);
static void osx_bmp_unlock(QEditScreen *s, QEBitmap *b);
static int osx_bmp_alloc(QEditScreen *s, QEBitmap *b);

id window; /* the main window */
int start_w = 550;
int start_h = 480;

static int osx_probe(void)
{
/* XXX: need to come back to this */
return 1;
}


static int osx_init(QEditScreen *s, int w, int h) 
{
[NSAutoreleasePool new];
[NSApplication sharedApplication];
[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

NSRect container_bg = NSMakeRect(0, 0, w, h);
window = [[[NSWindow alloc] initWithContentRect:container_bg
styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO]
autorelease];
NSRect background = NSMakeRect(0, 0, w, h);
NSView *view = [[NSView alloc] initWithFrame:background];
id menubar = [[NSMenu new] autorelease];
id appMenuItem = [[NSMenuItem new] autorelease];
[menubar addItem:appMenuItem];
[NSApp setMainMenu:menubar];
id appMenu = [[NSMenu new] autorelease];
id appName = [[NSProcessInfo processInfo] processName];
id quitTitle = [@"Quit " stringByAppendingString:appName];
id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle

action:@selector(terminate:) keyEquivalent:@"q"] autorelease];
[appMenu addItem:quitMenuItem];
[appMenuItem setSubmenu:appMenu];

[window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
[window setTitle:appName];
[window makeKeyAndOrderFront:nil];
[window setContentView:view];

[NSApp activateIgnoringOtherApps:YES];
[NSApp run];
}



static void osx_close(QEditScreen *s) {
[window close];
}


static void osx_flush(QEditScreen *s)
{

}

static int osx_is_user_input_pending(QEditScreen *s)
{
/* XXX: do it */
return 0;
}

static void osx_fill_rectangle(QEditScreen *s,
				 int x1, int y1, int w, int h, QEColor color)
{
  unsigned int r, g, b, a;
  a = (color >> 24) & 0xff;
  r = (color >> 16) & 0xff;
  g = (color >> 8) & 0xff;
  b = (color) & 0xff;
  // NSColor* rgbColor = [NSColor colorWithCalibratedRed:r green: g  blue: b  alpha:a];
  NSRect rect = NSMakeRect(x1, y1, w, h);
  [[NSColor cyanColor] set];
  NSRectFill(rect);
  [[window contentView] drawRect:rect];
}

static QEFont *osx_open_font(QEditScreen *s, int style, int size)
{
QEFont *font;
return font;
}

static void osx_close_font(QEditScreen *s, QEFont *font)
{
free(font);
}

static void osx_text_metrics(QEditScreen *s, QEFont *font, 
			       QECharMetrics *metrics,
			       const unsigned int *str, int len)
{
int i, x;
metrics->font_ascent = font->ascent;
metrics->font_descent = font->descent;
x = 0;
for(i=0;i<len;i++)
  x += 10; // font_xsize;
 metrics->width = x;
}


static void osx_draw_text(QEditScreen *s, QEFont *font,
			  int x1, int y, const unsigned int *str, int len,
			  QEColor color)
{

}

static void osx_set_clip(QEditScreen *s,
			 int x, int y, int w, int h)
{
  /* nothing to do */
}



int osx_driver_init () {
  static QEDisplay osx_dpy = {
    "osx",
    osx_probe,
    osx_init,
    osx_close,
    NULL,
    osx_flush,
    osx_is_user_input_pending,
    osx_fill_rectangle,
    osx_open_font,
    osx_close_font,
    osx_text_metrics,
    osx_draw_text,
    osx_set_clip,
    NULL, /* no selection handling */
    NULL, /* no selection handling */
    /*
      osx_selection_activate,
      osx_selection_request,
      osx_bmp_alloc,
      osx_bmp_free,
      osx_bmp_draw,
      osx_bmp_lock,
      osx_bmp_unlock,
      osx_full_screen;*/
  };
 
  return qe_register_display(&osx_dpy);
}

qe_module_init(osx_driver_init);

