@interface QEWindow : NSWindow
@end




@interface QERectLayer : NSView

@end

struct QE_OSX_Rect {
  NSRect frame;
  NSColor * color;
};

@interface QEMainView : NSView

@property NSRect clip;
@property QEStyleDef default_style;
@property (assign) IBOutlet QERectLayer *rect_layer;
@property (assign) int drawBackground;
@property (assign) struct QE_OSX_Rect *drawable_rects;

@end


@interface QEDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (assign) IBOutlet QEWindow *window;
@property (assign) IBOutlet QEMainView *view;
@property (assign) NSTimer *url_timer;

@property void (*qinit)(void *args);
@property void *qargs;

@end


@interface QEApplication : NSApplication
@end


