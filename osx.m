/*
 * OSX Driver for EMacs
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

static QEDisplay osx_dpy;

int osx_init () {
  static QEDisplay osx_dpy; {
    "osx";
      /*   term_probe,
	   term_init,
	   term_close,
	   NULL,
	   term_flush,
	   x11_is_user_input_pending,
	   term_fill_rectangle,
	   term_open_font,
	   term_close_font,
	   term_text_metrics,
	   term_draw_text,
	   term_set_clip,
	   term_selection_activate,
	   term_selection_request,
	   x11_bmp_alloc,
	   x11_bmp_free,
	   x11_bmp_draw,
	   x11_bmp_lock,
	   x11_bmp_unlock,
	   x11_full_screen
      */
      };

  [NSAutoreleasePool new];
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
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
  id window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
					   styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO]
		autorelease];
  [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
  [window setTitle:appName];
  [window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp run];

  return qe_register_display(&osx_dpy);
}

qe_module_init(osx_init);

