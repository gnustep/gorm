/* All rights reserved */

#include <AppKit/AppKit.h>
#include "GormCanvasView.h"

@implementation GormCanvasView

- (void)drawRect:(NSRect)dirtyRect
{
  NSRectFill(dirtyRect);
  
  for (int i = 1; i < [self bounds].size.height / 10; i++)
    {
      if (i % 10 == 0)
        {
          [[NSColor colorWithSRGBRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:0.3] set];
        }
      else if (i % 5 == 0)
        {
          [[NSColor colorWithSRGBRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:0.2] set];
        }
      else
        {
          [[NSColor colorWithSRGBRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:0.1] set];
        }
      
      [NSBezierPath strokeLineFromPoint: NSMakePoint(0, i * 10 - 0.5)
                                toPoint: NSMakePoint([self bounds].size.width, i * 10 - 0.5)];
  }

  for (int i = 1; i < [self bounds].size.width / 10; i++)
    {
      if (i % 10 == 0)
        {
          [[NSColor colorWithSRGBRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:0.3] set];
        }
      else if (i % 5 == 0)
        {
          [[NSColor colorWithSRGBRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:0.2] set];
        }
      else
        {
          [[NSColor colorWithSRGBRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:0.1] set];
        }
      
      [NSBezierPath strokeLineFromPoint: NSMakePoint(i * 10 - 0.5, 0)
                                toPoint: NSMakePoint(i * 10 - 0.5, [self bounds].size.height)];
    }
}

@end
