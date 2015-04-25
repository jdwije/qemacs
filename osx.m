
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
static int force_tty = 0;

static int osx_init(QEditScreen *s, int w, int h);
static void osx_close(QEditScreen *s);
static void osx_resize(QEditScreen *s, int w, int h);
static void osx_fill_rectangle(QEditScreen *s, int x1, int y1, int w, int h, QEColor color);
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
static int osx_qe_init();
static void osx_url_block(void);
static NSColor * get_ns_color(QEColor color);

int start_w = 550;
int start_h = 480;

id progname = @"QEmacs";
QEDelegate * delegate;
NSAutoreleasePool * pool;
NSApplication * application;
int dpy_rdy = 0;


@implementation QEApplication : NSApplication
@end

@implementation QEDelegate : NSObject

- (void)shutdown
{
  url_exit_request = 1; /* setting to 1 will make qeMainLoop() handle the rest of the shutdown procedure */
}

- (id)init :(int) w :(int) h {
  if (self = [super init]) {
    // allocate and initialize window and stuff here ..
    self.window = [[[QEWindow alloc] initWithContentRect:NSMakeRect(0, 0, w, h)
					       styleMask:  NSTitledWindowMask | NSClosableWindowMask | 
				     NSMiniaturizableWindowMask | NSResizableWindowMask
						 backing:NSBackingStoreBuffered defer:NO
    ] autorelease];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
					     selector:@selector(shutdown)
						 name:NSWindowWillCloseNotification
					       object:self.window];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self.window];


    [self.window setBackgroundColor:[NSColor whiteColor]];
    id menubar = [[NSMenu new] autorelease];
    id appMenuItem = [[NSMenuItem new] autorelease];
  
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];
  
    id appMenu = [[NSMenu new] autorelease];
    id appName = progname;
    id quitTitle = [@"Quit " stringByAppendingString:appName];
    id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
						  action:@selector(terminate:) keyEquivalent:@"q"] autorelease];

    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];
    [self.window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [self.window setTitle:appName];
    NSLog(@"init frame size   width:%f  height:%f", [self.window frame].size.width, [self.window frame].size.height );
  }
  return self;
}



- (void)windowDidResize:(NSNotification *)notification
{
  QEEvent ev1, *ev = &ev1;
  NSSize size = [[self.window contentView] frame].size;
  int w = (int) size.width, h = (int) size.height;
    
  self.screen_ref->width = w;
  self.screen_ref->height = h;
  self.view.drawBackground = 1;

  NSLog(@"%f", [self.window frame].size.height );
  NSLog(@"width:%i height:%i",w,h);

  ev->expose_event.type = QE_EXPOSE_EVENT;
  qe_handle_event(ev);
}

- (void)dealloc {

  [[NSNotificationCenter defaultCenter] removeObserver:self
						  name:NSWindowDidResizeNotification
						object:self.window];

  [[NSNotificationCenter defaultCenter] removeObserver:self
						  name:NSWindowWillCloseNotification
						object:self.window];


  [self.window release];
  [super dealloc];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  [self.window makeKeyAndOrderFront:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  /* initialisation code */
  NSLog(@"OSX GUI: window will initialise.");
  dpy_rdy = 1; /* set dpy ready for drawing */
  self.view = [[QEMainView alloc] initWithFrame:[[self.window contentView] bounds]];
  self.view.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
  [[self.window contentView] addSubview:self.view];

  if (self.view == nil || self.view.canDraw == NO)
    exit(0);

  url_block_reset();
  self.qinit(self.qargs);
  
  /* create thread to call the qeMainLoop fn without blocking, this is the OSX specific version
     of url_main_loop() in unix.c */
  NSLog(@"OSX GUI: qeMainLoop thread being created.");
  [NSThread detachNewThreadSelector:@selector(qeMainLoop)
			   toTarget:self withObject:nil];

}

- (void) qeMainLoop
{
  NSLog(@"OSX GUI: begining main loop.");

  while (!url_exit_request) {
    /* XXX: need to check how necessary is it to create an auto-release pool here */
    NSAutoreleasePool *pond = [[NSAutoreleasePool alloc] init];
    url_block();
    [pond release];
  }
  /* XXX: should do rest of qe cleanup here */
  [NSApp terminate:self];
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
  
}

@end

@implementation QERectLayer

- (void) drawRect:(NSRect)rect :(NSColor *)color {
  NSLog(@"OSX GUI [rect layer]: drawing rectangle %@", NSStringFromRect(rect));
  [color set];
  NSRectFill(rect);
  [self setNeedsDisplay:YES];
}

@end



@implementation QEMainView


- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font 
{
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
  return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


-(void)flushCleanup 
{
  int i;
  /* free things up first */
  
  [self.drawable_rects removeAllObjects];
  [self.drawable_text removeAllObjects];
}

-(QEMainView*)initWithFrame:(NSRect)rect 
{
  [super initWithFrame:rect];
  if (self) {
    // self.rect_layer = [[QERectLayer alloc] initWithFrame:[self bounds]];
    // self.rect_layer.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
    // [self doDrawBackground];
    // [self addSubview:self.rect_layer];
    self.drawBackground = 1;
    self.flush_request = NO;
    // self.drawable_rects = malloc(sizeof(struct QE_OSX_Rect) * 3);
    self.drawable_rects = [[NSMutableArray alloc] init];
    self.drawable_text = [[NSMutableArray alloc] init];
  }
  return self;
}

-(QEFont *)openFont :(CGFloat)size :(int)style

{
  QEFont *font;
  font = malloc(sizeof(QEFont));
  
  if (!font)
    return NULL;
  
  NSFont *qfont = [[NSFont fontWithName:@"Monaco" size:size] retain];
  NSLog(@"qfont %@", qfont);
  
  self.current_font = qfont;

  font->ascent = (int) [qfont ascender];
  font->descent = (int) ([qfont descender] * -1);
  font->private = qfont;
  
  NSLog(@"font ascender ns:%f qe:%i", [qfont ascender], font->ascent);
  NSLog(@"font descender ns:%f qe:%i", [qfont descender], font->descent);

  return font;
}

- (void) setClipRectangle :(int)x :(int)y :(int)w :(int)h {
  NSLog(@"OSX GUI: creating clip rect.");
  NSLog(@"%i %i %i %i", x,y,w,h);
  if (x == 0 && y == 0 && w == 0 && h == 0) {
    NSRect mainFrame = [[self.window contentView] bounds];
    [self setClip:NSMakeRect(mainFrame.origin.x, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height)];
  }
  else {
    [self setClip:NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)w, (CGFloat)h)];
  }
}


- (void) drawText :(NSString *)text :(int)x1 :(int)y :(NSColor*)color {
  struct QE_OSX_Text qstruct;
  qstruct.text = text;
  qstruct.color = color;
  qstruct.x = (CGFloat) x1;
  qstruct.y = (CGFloat) y;
  qstruct.font = self.current_font;
  NSLog(@"adding to text drawables");
  [self.drawable_text addObject:[NSValue valueWithBytes:&qstruct objCType:@encode(struct QE_OSX_Text)]];
}

- (void) drawRect:(NSRect)rect {
  int i;
  
  if (self.flush_request == NO) /* ony draw if requested by QE Core */
    return;

  if (self.drawBackground > 0) {
    [self doDrawBackground];
    self.drawBackground = 0;
  }
  
  for (NSValue *item in [self drawable_rects]) {
    struct QE_OSX_Rect c_rect;
    [item getValue:&c_rect];
    [self intDrawRect :c_rect.frame :c_rect.color];
    i++;
  }
  
  NSLog(@"text count: %i",[self.drawable_text count]);

  for (NSValue *item in [self drawable_text]) {
    struct QE_OSX_Text c_text;
    [item getValue:&c_text];
    [self intDrawText :c_text.text :c_text.x :c_text.y :c_text.color :c_text.font];
  }
  
  [self flushCleanup]; /* cleanup our drawable arrays and dealloc as required */
  
  self.flush_request = NO; /* reset to 'NO' since we are done drawing. QE Core will set this to 'YES'
			      when a redraw is required */
}


- (void) intDrawText :(NSString *)text :(CGFloat)x1 :(CGFloat)y :(NSColor*)color :(NSFont*)font {
  NSMutableDictionary * stringAttributes;
  NSRect bounds = [self bounds];
  CGFloat adj_y = ((CGFloat) bounds.size.height) - ((CGFloat) y); // + (CGFloat) 10;
  stringAttributes = [NSMutableDictionary dictionary];
  [stringAttributes setObject:font forKey:NSFontAttributeName];
  [stringAttributes setObject:color forKey:NSForegroundColorAttributeName];
  [stringAttributes retain];
  
  NSLog(@"OSX GUI: inserting text at x:%f adj_y:%f  y:%f.", x1, adj_y, y);
  NSLog(@"OSX GUI: inserting text in bounds: %@", NSStringFromRect(bounds));
  NSLog(@"OSX GUI: inserting text with QE bounds: width:%i height:%i", delegate.screen_ref->width, delegate.screen_ref->height);
  [text drawAtPoint:NSMakePoint((CGFloat)x1, (CGFloat)adj_y) withAttributes:stringAttributes];
  [stringAttributes release];
}

- (void) intDrawRect:(NSRect)rect :(NSColor*)c {
  [c set];
  NSRect bounds = [self bounds];
  NSRect adj_rect = NSMakeRect( rect.origin.x, (bounds.size.height - rect.origin.y), rect.size.width, rect.size.height );
  NSRectFill(adj_rect);
}

- (void) doDrawBackground {
  NSLog(@"OSX GUI: filling background rectangle.");
  QEStyleDef default_style;
  get_style(NULL, &default_style, 0);
  NSColor* c = get_ns_color(default_style.bg_color);
  [c set];
  NSRectFill([[self.window contentView] bounds]);
}

- (void) drawRect:(NSRect)rect :(NSColor *)color {
  struct QE_OSX_Rect qstruct;
  qstruct.frame = rect;
  qstruct.color = color;
  [self.drawable_rects addObject:[NSValue valueWithBytes:&qstruct objCType:@encode(struct QE_OSX_Rect)]];
}

- (void)viewDidLoad {
  NSLog(@"OSX GUI: main view did load.");
  [super viewDidLoad];
}

@end



//////////////////////////////////////////////////////////////////////////
// THE REST OF THE METHODS BIND THE COCOA APPLICATION TO THE QE DPY API //
//////////////////////////////////////////////////////////////////////////



/* converts a QEColor to an NSColor */
static NSColor * get_ns_color(QEColor color) {
  unsigned int r,g,b,a;
  CGFloat a_adj;
  a = (color >> 24) & 0xff;
  r = (color >> 16) & 0xff;
  g = (color >> 8) & 0xff;
  b = (color) & 0xff;

  NSLog(@"raw r:%i g:%i b:%i a:%i", r,g,b,a);
  
  a_adj = (CGFloat) (a/255); /* convert to percentage between 0-1 */

  NSLog(@"filtered r:%i g:%i b:%i a:%f", r,g,b,a_adj);

  return [[NSColor colorWithCalibratedRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a_adj] retain];
}

/* converts qe str to NSString equivalent */
static NSString* get_ns_string (const unsigned int *str, int len) {
  int i;
  char cstr[len];
  for(i=0;i<len;i++) {
    cstr[i] = (char) str[i];
  }
  NSString *nstr = [[NSString alloc] initWithCString:cstr length:len];
  return nstr;
}

static int osx_probe(void)
{
  /* XXX: we might not need to fully impliment this because this method should only be called after the display is 
     already initialised due to overriding the main loop! need to double check however... */
  NSLog(@"QE API: probing display.");
  return 1;
}

static int osx_init(QEditScreen *s, int w, int h) 
{

  NSLog(@"QE API: initialising display with width:%i and height:%i.", w, h);
  memcpy(&s->dpy, &osx_dpy, sizeof(QEDisplay));

  //  NSRect frame = [delegate.window frame];
  //  [delegate.window setFrame:NSMakeRect(frame.origin.x,frame.origin.y, start_width, start_height) display:YES];
  NSRect bounds = [delegate.view bounds];
  NSLog(@"sizes::: %i   %i", bounds.size.width, w);
  NSLog(@"sizes::: %i   %i", bounds.size.height, h);
  NSLog(@"%@", NSStringFromRect(bounds));
  [delegate.view doDrawBackground];
  s->width = 750;
  s->height = 500;
  s->charset = &charset_utf8;
  s->clip_x1 = 0;
  s->clip_y1 = 0;
  s->clip_x2 = s->width;
  s->clip_y2 = s->height;
  
  delegate.screen_ref = s;

  return 1;
}



static void osx_close(QEditScreen *s) {
  NSLog(@"QE API: closing down GUI");
  //   [window close];
}


static void osx_flush(QEditScreen *s)
{
  NSLog(@"QE API: flushing screen.");
  delegate.view.flush_request = YES;
}

static int osx_is_user_input_pending(QEditScreen *s)
{
  /* XXX: do it */
  return 0;
}

static void osx_fill_rectangle(QEditScreen *s,
			       int x1, int y1, int w, int h, QEColor color)
{
  NSLog(@"QE API: filling rectangle at x1:%i y1:%i w:%i h:%i.", x1, y1, w,h);
  NSLog(@"Our color value is %@", get_ns_color(color));
  NSColor *c = get_ns_color(color);
  [delegate.view drawRect:NSMakeRect(x1,y1,w,h) :c];
}

static QEFont *osx_open_font(QEditScreen *s, int style, int fontsize)
{
  NSLog(@"QE API: opening font.");
  /* XXX: come back to this! */
  // typedef struct QEFont {
  //     int ascent;
  //     int descent;
  //     void *private;
  //     int system_font; /* TRUE if system font */
  //     /* cache data */
  //     int style;
  //     int size;
  //     int timestamp;
  // } QEFont;
  QEFont *font = [delegate.view openFont :fontsize :style];

  return font;
}

static void osx_close_font(QEditScreen *s, QEFont *font)
{
  NSLog(@"QE API: closing font.");
  [font->private realease];
  free(font);
}

static void osx_text_metrics(QEditScreen *s, QEFont *font, 
			     QECharMetrics *metrics,
			     const unsigned int *str, int len)
{
  NSLog(@"QE API: getting text metrics");
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font->private, NSFontAttributeName, nil];
  NSSize str_size = [[[NSAttributedString alloc] initWithString:get_ns_string(str,len) attributes:attributes] size];
  metrics->font_ascent = font->ascent;
  metrics->font_descent = font->descent;
  metrics->width = (int) str_size.width;
}


static void osx_draw_text(QEditScreen *s, QEFont *font,
			  int x1, int y, const unsigned int *str, int len,
			  QEColor color)
{
  NSLog(@"QE API: drawing text.");
  [delegate.view drawText :get_ns_string(str,len) :(CGFloat)x1 :(CGFloat)(y - 10) :get_ns_color(color)];
}

static void osx_set_clip(QEditScreen *s,
			 int x, int y, int w, int h)
{
  NSLog(@"QE API: setting clip rectangle.");
  NSLog(@"%i %i %i %i",x,y,w,h);
  [delegate.view setClipRectangle:x :y :w :h];
}

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
  /* bitmap support */
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  /* fullscreen support */
  NULL,
};

void osx_main_loop(void (*init)(void *opaque), void *opaque)
{
  NSLog(@"QE API: entering osx main loop.");
  pool = [NSAutoreleasePool new];
  application = [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];
  
  delegate = [[[QEDelegate alloc] init:750 :500] autorelease];
  [application setDelegate:delegate];
  
  delegate.qinit = init;
  delegate.qargs = opaque;

  [NSApp run];
  [pool drain];
}

int osx_driver_init () {
  qe_register_display(&osx_dpy);
  return 1;
}


qe_module_init(osx_driver_init);
