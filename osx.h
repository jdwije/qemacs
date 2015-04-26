@interface QEWindow : NSWindow
@end




@interface QERectLayer : NSView

@end

typedef struct QE_OSX_Rect {
  NSRect frame;
  NSColor * color;
};


typedef struct QE_OSX_Text {
  NSString *text;
  NSFont *font;
  NSColor *color;
  CGFloat x;
  CGFloat y;
};

@interface QEMainView : NSView

@property NSRect clip;
@property QEStyleDef default_style;
@property (assign) IBOutlet QERectLayer *rect_layer;
@property (assign) int drawBackground;
@property (assign) NSMutableArray *drawable_rects;
@property (assign) NSFont *current_font;
@property (assign) NSMutableArray *drawable_text;

@property (assign) Boolean flush_request;

@end


@interface QEDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (assign) IBOutlet QEWindow *window;
@property (assign) IBOutlet QEMainView *view;
@property (assign) NSTimer *url_timer;

@property void (*qinit)(void *args);
@property void *qargs;
@property (assign) QEditScreen *screen_ref;

@end


@interface QEApplication : NSApplication
@end



#define OSXK_ESC 53;

#define OSXK_LEFT 123;
#define OSXK_RIGHT 124;
#define OSXK_DOWN 125;
#define OSXK_UP 126;

#define OSXK_F1 122;
#define OSXK_F2 120;
#define OSXK_F3 99;
#define OSXK_F4 118;
#define OSXK_F5 96;
#define OSXK_F6 97;
#define OSXK_F7 98;
#define OSXK_F8 100;

#define OSXK_F9 101;
#define OSXK_F10 109;
#define OSXK_F11 103;
#define OSXK_F12 111;

