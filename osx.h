@interface QEWindow : NSWindow
@end

@interface QEMainView : NSView

@property NSRect clip;

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


