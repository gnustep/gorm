/* GormCanvasView.m
 *
 * Copyright (C) 2021 Free Software Foundation, Inc.
 *
 * Author:      Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:        2021
 *
 * This file is part of GNUstep.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */

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

  [super drawRect: dirtyRect];
}

@end
