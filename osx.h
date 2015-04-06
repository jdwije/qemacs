@interface QEWindow : NSWindow

@end

@interface QEView : NSView

@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

  @property (assign) IBOutlet QEWindow *window;
  @property (assign) IBOutlet QEView *view;

@end

