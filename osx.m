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

/* some specific stuff required from unix.c */
int url_exit_request;
void url_block_reset(void);
void url_block(void);



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

static void osx_url_block(void);
static NSColor * qe2nscolor(QEColor color);

int start_w = 550;
int start_h = 480;

//id window; /* reference to the main window object */
id PROGNAME = @"QEmacs"; /* used for title of applications throughout osx UI */
AppDelegate * DELEGATE;
NSAutoreleasePool * pool;
NSApplication * application;


/* the main cocoa application container */
@implementation AppDelegate : NSObject


- (id)init :(int) w :(int) h {
     if (self = [super init]) {
      // allocate and initialize window and stuff here ..
      self.window = [[[QEWindow alloc] initWithContentRect:NSMakeRect(0, 0, w, h)
						 styleMask:  NSTitledWindowMask | NSClosableWindowMask | 
				                              NSMiniaturizableWindowMask | NSResizableWindowMask
							        backing:NSBackingStoreBuffered defer:NO
                                                           ] autorelease];
      [self.window setBackgroundColor:[NSColor whiteColor]];
      id menubar = [[NSMenu new] autorelease];
      id appMenuItem = [[NSMenuItem new] autorelease];
  
      [menubar addItem:appMenuItem];
      [NSApp setMainMenu:menubar];
  
      id appMenu = [[NSMenu new] autorelease];
      id appName = PROGNAME;
      id quitTitle = [@"Quit " stringByAppendingString:appName];
      id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
						    action:@selector(terminate:) keyEquivalent:@"q"] autorelease];

      [appMenu addItem:quitMenuItem];
      [appMenuItem setSubmenu:appMenu];
      [self.window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
      [self.window setTitle:appName];
      
      id timer = [NSTimer timerWithTimeInterval: 0.0f
                                    target: self
                                  selector: @selector( timerFired: )
                                  userInfo: nil
				repeats: YES];

      [[NSRunLoop currentRunLoop] addTimer: timer
				   forMode: NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc {
    [self.window release];
    [super dealloc];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  [self.window makeKeyAndOrderFront:self];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  /* initialisation code */
  self.view = [[QEMainView alloc] initWithFrame:[[self.window contentView] bounds]];
  self.view.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
  [[self.window contentView] addSubview:self.view];
  if (self.view == nil || self.view.canDraw == NO) {
    exit(0);
  }
}


// This is in the Application controller class.
- (void) timerFired: (id) blah
{
    if (url_exit_request) {
      [NSApp terminate:self];
    }
    url_block();
}

@end


/* A Cocoa Window container object with event handling methods integrated */
@implementation QEWindow

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)canBecomeKeyWindow
{
  return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
  QEEvent ev1, *ev = &ev1;
  int key;

  if ([theEvent modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
    NSString *theArrow = [theEvent charactersIgnoringModifiers];
    unichar keyChar = 0;
    if ( [theArrow length] == 0 )
      return;            // reject dead keys
    if ( [theArrow length] == 1 ) {
      keyChar = [theArrow characterAtIndex:0];
      if ( keyChar == NSLeftArrowFunctionKey ) {
	key = KEY_LEFT;
      }
      if ( keyChar == NSRightArrowFunctionKey ) {
	key = KEY_RIGHT;
      }
      if ( keyChar == NSUpArrowFunctionKey ) {
	key = KEY_UP;
      }
      if ( keyChar == NSDownArrowFunctionKey ) {
	key = KEY_DOWN;
      }
      //      [super keyDown:theEvent];
    }
  }
  else {
    
  }

  ev->key_event.type = QE_KEY_EVENT;
  ev->key_event.key = key;
  qe_handle_event(ev);

  [super keyDown:theEvent];
}

// The following action methods are declared in NSResponder.h
- (void)insertTab:(id)sender {
  QEEvent ev1, *ev = &ev1;
    if ([[self window] firstResponder] == self) {
      ev->key_event.type = QE_KEY_EVENT;
      ev->key_event.key = KEY_SHIFT_TAB;
      qe_handle_event(ev);
    }
}
 
- (void)insertBacktab:(id)sender {
  QEEvent ev1, *ev = &ev1;
    if ([[self window] firstResponder] == self) {
      ev->key_event.type = QE_KEY_EVENT;
      ev->key_event.key = KEY_SHIFT_TAB;
      qe_handle_event(ev);
    }
}
 
- (void)insertText:(id)string {
  //    [super insertText:string];  // have superclass insert it
}

@end


@implementation QEMainView

- (void) drawRect:(NSRect)rect {
  /* XXX: comeback and hook in BG style here */
  [[NSColor blackColor] set];
  NSRectFill([[self.window contentView] bounds]);
}


- (void) drawRect:(NSRect)rect :(NSColor *)color {
  //   [super drawRect:rect];
  NSLog(@"drawing rectangle");

  // This next line sets the the current fill color parameter of the Graphics Context
  // [[NSColor colorWithCalibratedRed:r green: g  blue: b  alpha:1.0] setFill];
  [color set];
  // This next function fills a rect the same as dirtyRect with the current fill color of the Graphics Context.
  NSRectFill(rect);
  // You might want to use _bounds or self.bounds if you want to be sure to fill the entire bounds rect of the view. 
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"view loaded into memory");
}

@end



 /////////////////////////////////////////////////////////////////////
 // THE REST OF THE METHODS BIND THE COCOA OBJECT TO THE QE DPY API //
 /////////////////////////////////////////////////////////////////////

void osx_main_loop(void (*init)(void *opaque), void *opaque)
{
  NSLog(@"entering osx main loop");
  url_block_reset();
  init(opaque);
  [NSApp run];
  // for(;;) {
  //   if (url_exit_request)
  //     break;
  //   url_block();
  // }
  [pool drain];
}

static int osx_probe(void)
{
  /* XXX: need to come back to this */
  return 1;
}

static int osx_init(QEditScreen *s, int w, int h) 
{
  pool = [NSAutoreleasePool new];
  application = [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  DELEGATE = [[[AppDelegate alloc] init:(w*14) :(h*14)] autorelease];
  [application setDelegate:DELEGATE];
  //  memcpy(&s->dpy, &window, sizeof(QEDisplay));
  [NSApp activateIgnoringOtherApps:YES];
  return 1;
}



static void osx_close(QEditScreen *s) {
  //   [window close];
}


static void osx_flush(QEditScreen *s)
{
  
}

static int osx_is_user_input_pending(QEditScreen *s)
{
  /* XXX: do it */
  return 0;
}

static NSColor * qe2nscolor(QEColor color) {
  int r,g,b,a;
  a = (color >> 24) & 0xff;
  r = (color >> 16) & 0xff;
  g = (color >> 8) & 0xff;
  b = (color) & 0xff;

  NSLog(@" r:%d g:%d b:%d a:%d", r,g,b,a);

  if (a > 1)
    a / 100;
  return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
}

static void osx_fill_rectangle(QEditScreen *s,
				 int x1, int y1, int w, int h, QEColor color)
{
  NSLog(@"osx_fill_rectangle is being called");
  [DELEGATE.view drawRect:NSMakeRect(x1,y1,w,h) :[NSColor blueColor]];
}

static QEFont *osx_open_font(QEditScreen *s, int style, int size)
{
  /* XXX: come back to this! */
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
  /* XXX: do we even need to impliment an OSX specific version of this function? */
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
  /* XXX: come back to this! */
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:26], NSFontAttributeName,[NSColor blackColor], NSForegroundColorAttributeName, nil];

  NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:str attributes: attributes];

  NSSize attrSize = [currentText size];
  [currentText drawAtPoint:NSMakePoint(x1, y)];

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
      osx_full_screen;
    */
  };
 
  return qe_register_display(&osx_dpy);
}

qe_module_init(osx_driver_init);

