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


