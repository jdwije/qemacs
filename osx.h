@interface QEWindow : NSWindow

@end

@interface QEMainView : NSView

@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

  @property (assign) IBOutlet QEWindow *window;
  @property (assign) IBOutlet QEMainView *view;

@end

