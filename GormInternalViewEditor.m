/* GormInternalViewEditor.m
 *
 * Copyright (C) 2002 Free Software Foundation, Inc.
 *
 * Author:	Pierre-Yves Rivaille <pyrivail@ens-lyon.fr>
 * Date:	2002
 * 
 * This file is part of GNUstep.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#import <AppKit/AppKit.h>

#import "GormPrivate.h"

#import "GormInternalViewEditor.h"

@class GormEditorToParent;
@class GSWindowView;

@implementation NSView (GormObjectAdditions)
- (NSString*) editorClassName
{
  if ([self superview] && 
      (([[self superview] respondsToSelector: @selector(contentView)] &&
	[(id)[self superview] contentView] == self) 
       ||
       [[self superview] isKindOfClass: [NSTabView class]]
       || 
       [[self superview] isKindOfClass: [GSWindowView class]]
       ))
    {
      return @"GormInternalViewEditor";
    }
  else
    {
      return @"GormViewEditor";
    }
}
@end


@implementation GormInternalViewEditor

- (void) dealloc
{
  RELEASE(selection);
  [super dealloc];
}


- (BOOL) activate
{
  if (activated == NO)
    {
      NSEnumerator	*enumerator;
      NSView		*sub;
      NSView *superview = [_editedObject superview];

//        NSLog(@"ac %@ %@ %@", self, _editedObject, superview);

      
      [self setFrame: [_editedObject frame]];
      [self setBounds: [self frame]];

      if ([superview isKindOfClass: [NSBox class]])
	{
	  NSBox *boxSuperview = (NSBox *) superview;
	  [boxSuperview setContentView: self];
	}
      else if ([superview isKindOfClass: [NSTabView class]])
	{
	  NSTabView *tabSuperview = (NSTabView *) superview;
	  [tabSuperview removeSubview: 
			  [[tabSuperview selectedTabViewItem] view]];
	  [[tabSuperview selectedTabViewItem] setView: self];
	  [tabSuperview addSubview: self];
	  [self setFrame: [tabSuperview contentRect]];
	  [self setAutoresizingMask: 
		  NSViewWidthSizable | NSViewHeightSizable];
//  	  NSLog(@"ac %d %d %d", 
//  		[tabSuperview autoresizesSubviews],
//  		[self autoresizesSubviews],
//  		[_editedObject autoresizesSubviews]);
	}
      else if ([superview isKindOfClass: [GSWindowView class]])
	{
	  [[superview window] setContentView: self];
	}

      [self addSubview: _editedObject];
      
      [_editedObject setPostsFrameChangedNotifications: YES];
      [[NSNotificationCenter defaultCenter]
	addObserver: self
	selector: @selector(editedObjectFrameDidChange:)
	name: NSViewFrameDidChangeNotification
	object: _editedObject];
      
      [self setPostsFrameChangedNotifications: YES];
      [[NSNotificationCenter defaultCenter]
	addObserver: self
	selector: @selector(frameDidChange:)
	name: NSViewFrameDidChangeNotification
	object: self];

      parent = [document parentEditorForEditor: self];
      
      if ([parent isKindOfClass: [GormViewEditor class]])
	[parent setNeedsDisplay: YES];
      else
	[self setNeedsDisplay: YES];
      activated = YES;



      enumerator = [[NSArray arrayWithArray: [_editedObject subviews]]
		     objectEnumerator];

      while ((sub = [enumerator nextObject]) != nil)
	{
//  	  NSLog(@"ac %@ editorForObject: %@", self, sub);
	  if ([sub isKindOfClass: [GormViewEditor class]] == NO)
	    {
//  	      NSLog(@"ac %@ yes", self);
	      [document editorForObject: sub
			inEditor: self
			create: YES];
	    }
	}
      return YES;
    }

  return NO;
}


//  - (void) close
//  {
//    NSEnumerator	*enumerator;
//    GormViewEditor	*sub;
  
//    enumerator = [[NSArray arrayWithArray: [_editedObject subviews]]
//  		 objectEnumerator];
  
//    while ((sub = [enumerator nextObject]) != nil)
//      {
//        if ([sub respondsToSelector: @selector(deactivate)] == NO)
//  	{
//  	}
//        else
//  	{
//  	  NSLog(@"deactivating, deac %@", sub);
//  	  [sub deactivate];
//  	}
//      }
//  }

- (void) deactivate
{
  if (activated == YES)
    {
      NSView *superview = [self superview];
      
      [self deactivateSubeditors];
      
      if ([superview isKindOfClass: [NSBox class]])
	{
	  NSBox *boxSuperview = (NSBox *) superview;
	  [self removeSubview: _editedObject];
	  [boxSuperview setContentView: _editedObject];
	}
      else if ([superview isKindOfClass: [NSTabView class]])
	{
//  	  NSLog(@"deactivating %@", self);
	  NSTabView *tabSuperview = (NSTabView *) superview;
	  [tabSuperview removeSubview: self];
	  [[tabSuperview selectedTabViewItem] 
	    setView: _editedObject];
	  [tabSuperview addSubview: 
			  [[tabSuperview selectedTabViewItem] view]];
	  [[[tabSuperview selectedTabViewItem] view] 
	    setFrame: [tabSuperview contentRect]];
	}
      else if ([superview isKindOfClass: [GSWindowView class]])
	{
	  [self removeSubview: _editedObject];
	  [[superview window] setContentView: _editedObject];
	}
      [[NSNotificationCenter defaultCenter] removeObserver: self];

    }
  
  activated = NO;
}

- (id) initWithObject: (id)anObject 
	   inDocument: (id<IBDocuments>)aDocument
{
  opened = NO;
  openedSubeditor = nil;

  if ((self = [super initWithObject: anObject
		     inDocument: aDocument]) == nil)
    return nil;

  selection = [[NSMutableArray alloc] initWithCapacity: 5];


  
  [self registerForDraggedTypes: [NSArray arrayWithObjects:
    IBViewPboardType, GormLinkPboardType, IBFormatterPboardType, nil]];
  
  return self;
}


//  - (void) reactivateWithObject: (id) anObject
//  		   inDocument: (id<IBDocuments>)aDocument
//  {
//    [super reactivateWithObject: anObject
//  	 inDocument: aDocument];
  
//  }


- (void) makeSelectionVisible: (BOOL) value
{
  
}


- (NSArray*) selection
{
  int i;
  int count = [selection count];
  NSMutableArray *result = [NSMutableArray arrayWithCapacity: count];
  
  if (count != 0)
    {
      for (i = 0; i < count; i++)
	{
	  [result addObject: [[selection objectAtIndex: i] editedObject]];
	}
    }
  else
    {
      return [parent selection];
    }

  return result;
}



- (void) deleteSelection
{
  int i;
  int count = [selection count];
  id temp;
  
  for (i = count - 1; i >= 0; i--)
    {
      temp = [[selection objectAtIndex: i] editedObject];

      [[selection objectAtIndex: i] detachSubviews];
      [document detachObject: temp];
      [[selection objectAtIndex: i] close];

      [temp removeFromSuperview];
      [selection removeObjectAtIndex: i];
    }
  
  [self selectObjects: [NSArray array]];
  
}



- (void) mouseDown: (NSEvent *) theEvent
{
  BOOL onKnob = NO;

  {
    if ([parent respondsToSelector: @selector(selection)] &&
	[[parent selection] containsObject: _editedObject])
      {
	IBKnobPosition	knob = IBNoneKnobPosition;
	NSPoint mouseDownPoint = 
	  [self convertPoint: [theEvent locationInWindow]
		fromView: nil];
	knob = GormKnobHitInRect([self bounds], 
				 mouseDownPoint);
	if (knob != IBNoneKnobPosition)
	  onKnob = YES;
      }
    if (onKnob == YES)
      {
	if (parent)
	  return [parent mouseDown: theEvent];
	else
	  return [self noResponderFor: @selector(mouseDown:)];
      }
  }
  
  {
    if ([parent isOpened] == NO)
      {
	NSDebugLog(@"md %@ calling my parent %@", self, parent);
	[super mouseDown: theEvent];
	return;
      }
  }

  // are we on the knob of a selected view ?
  {
    int count = [selection count];
    int i;
    GormViewEditor *knobView = nil;
    IBKnobPosition	knob = IBNoneKnobPosition;
    NSPoint mouseDownPoint;

    for ( i = 0; i < count; i++ )
      {
	mouseDownPoint = [[[selection objectAtIndex: i] superview] 
			   convertPoint: [theEvent locationInWindow]
			   fromView: nil];

	knob = GormKnobHitInRect([[selection objectAtIndex: i] frame], 
				 mouseDownPoint);
	  
	if (knob != IBNoneKnobPosition)
	  {
	    knobView = [selection objectAtIndex: i];
	    [self selectObjects: [NSMutableArray arrayWithObject: knobView]];
	    // we should set knobView as the only view selected
	    break;
	  }
      }
    
    if ( openedSubeditor != nil )
      {
	mouseDownPoint = [[openedSubeditor superview] 
			   convertPoint: [theEvent locationInWindow]
			   fromView: nil];

	knob = GormKnobHitInRect([openedSubeditor frame], 
				 mouseDownPoint);
	if (knob != IBNoneKnobPosition)
	  {
	    knobView = openedSubeditor;
	    // we should take back the selection
	    // we should select openedSubeditor only
	    [self selectObjects: [NSMutableArray arrayWithObject: knobView]];
	    [[self window] disableFlushWindow];
	    [self display];
	    [[self window] enableFlushWindow];
	    [[self window] flushWindow];
	  }
      }


    if (knobView != nil)
      {
	[self handleMouseOnKnob: knob
	      ofView: knobView
	      withEvent: theEvent];
	//	NSLog(@"resize %@", knobView);
	[self setNeedsDisplay: YES];
	return;
      }
  }

  {
    GormViewEditor *editorView;

    // get the view we are on
    {
      NSPoint mouseDownPoint;
      NSView *result;
      GormViewEditor *theParent;
      
      mouseDownPoint = [self
			 convertPoint: [theEvent locationInWindow]
			 fromView: nil];
      
      result = [_editedObject hitTest: mouseDownPoint];
      
//        NSDebugLog(@"md %@ result %@", self, result);
//        NSLog(@"_editedObject %@", _editedObject);

      // we should get a result which is a direct subeditor
      {
	id temp = result;
//  	int i = 0;

//  	NSLog(@"md %@ parent %@", self, parent);
	if ([temp isKindOfClass: [GormViewEditor class]])
	  theParent = [(GormViewEditor *)temp parent];
	while ((temp != nil) && (theParent != self) && (temp != self))
	  {
//  	    NSLog(@"md %@ temp = %@", self, temp);
	    temp = [temp superview];
	    while (![temp isKindOfClass: [GormViewEditor class]])
	      {
//  		if (i++ > 100)
//  		  sleep(3);
//  		NSLog(@"md %@ temp = %@", self, temp);
		temp = [temp superview];
	      }
	    theParent = [(GormViewEditor *)temp parent];
//  	    NSLog(@"temp (%@) 's parent is %@", temp, theParent);
	  }
//  	NSLog(@"md %@ temp = %@", self, temp);
	if (temp != nil)
	  {
	    result = temp;
	  }
	else
	  {
	    NSLog(@"WARNING -- strange case");
	    result = self;
	  }
      }


      if ([result isKindOfClass: [GormViewEditor class]])
	{
	  /*
	  if (result != self)
	    {
	      [self selectObjects: [NSMutableArray arrayWithObject: result]];
	    }
	  else
	    {
	      [self selectObjects: [NSMutableArray array]];
	    }
	  [[self window] disableFlushWindow];
	  [self display];
	  [[self window] enableFlushWindow];
	  [[self window] flushWindow];
	  NSLog(@"clicked on %@", result);
	  */
	}
      else
	{
//  	  NSLog(@"md %@ result = nil", self);
	  result = nil;
	}

      editorView = (GormViewEditor *)result;
    }

    if (([theEvent clickCount] == 2) 
	&& [editorView isKindOfClass: [GormViewWithSubviewsEditor class]]
	&& ([(id)editorView canBeOpened] == YES)
	&& (editorView != self))
       
      {
	[(GormViewWithSubviewsEditor *) editorView setOpened: YES];
	[self silentlyResetSelection];
	openedSubeditor = (GormViewWithSubviewsEditor *) editorView;
	[self setNeedsDisplay: YES];
//  	NSLog(@"md %@ editor should open", self);
	return;
      }

    if (editorView != self)
      {
	[self handleMouseOnView: editorView
	      withEvent: theEvent];
      }
    else // editorView == self
      {
//  	NSLog(@"editorView == self");
	[self selectObjects: [NSMutableArray array]];
	[self setNeedsDisplay: YES];
      }
    
  }


  /*
  // are we on a selected view ?
  {
    int count = [selection count];
    int i;
    BOOL inView = NO;
    NSPoint mouseDownPoint;
    

    for ( i = 0; i < count; i++ )
      {
	mouseDownPoint = [[[selection objectAtIndex: i] superview] 
			   convertPoint: [theEvent locationInWindow]
			   fromView: nil];

	if ([[[selection objectAtIndex: i] superview] 
	      mouse: mouseDownPoint
	      inRect: [[selection objectAtIndex: i] frame]])
	  {
	    inView = YES;
	    break;
	  }
      }

    if (inView)
      {
	NSLog(@"inside %@", [selection objectAtIndex: i]);
	return;
      }
  }
  */
  // are we on a view ?
  
}



- (unsigned) draggingEntered: (id<NSDraggingInfo>)sender
{
  NSRect rect = [_editedObject bounds];
  NSPoint loc = [sender draggingLocation];
  loc = [_editedObject convertPoint: loc fromView: nil];

  if (NSMouseInRect(loc, [_editedObject bounds], NO) == NO)
    {
      return NSDragOperationNone;
    }
  else
    {
      rect.origin.x += 3;
      rect.origin.y += 2;
      rect.size.width -= 5;
      rect.size.height -= 5;
      
      [_editedObject lockFocus];
      
      [[NSColor darkGrayColor] set];
      NSFrameRectWithWidth(rect, 2);
      
      [_editedObject unlockFocus];
      [[self window] flushWindow];
      return NSDragOperationCopy;
    }
}

- (void) draggingExited: (id<NSDraggingInfo>)sender
{
  NSRect rect = [_editedObject bounds];
  rect.origin.x += 3;
  rect.origin.y += 2;
  rect.size.width -= 5;
  rect.size.height -= 5;
 
  rect.origin.x --;
  rect.size.width ++;
  rect.size.height ++;

  [[self window] disableFlushWindow];
  [self displayRect: 
	  [_editedObject convertRect: rect
			 toView: self]];
  [[self window] enableFlushWindow];
  [[self window] flushWindow];
}

- (unsigned int) draggingUpdated: (id<NSDraggingInfo>)sender
{
  NSPoint loc = [sender draggingLocation];
  NSRect rect = [_editedObject bounds];
  loc = [_editedObject 
	  convertPoint: loc fromView: nil];

  rect.origin.x += 3;
  rect.origin.y += 2;
  rect.size.width -= 5;
  rect.size.height -= 5;

  if (NSMouseInRect(loc, [_editedObject bounds], NO) == NO)
    {
      [[self window] disableFlushWindow];
      rect.origin.x --;
      rect.size.width ++;
      rect.size.height ++;
      [self displayRect: 
	      [_editedObject convertRect: rect
			     toView: self]];
      [[self window] enableFlushWindow];
      [[self window] flushWindow];
      return NSDragOperationNone;
    }
  else
    {
      [_editedObject lockFocus];
      
      [[NSColor darkGrayColor] set];
      NSFrameRectWithWidth(rect, 2);
      
      [_editedObject unlockFocus];
      [[self window] flushWindow];
      return NSDragOperationCopy;
    }
}


- (BOOL) prepareForDragOperation: (id<NSDraggingInfo>)sender
{
  NSString		*dragType;
  NSArray *types;
  NSPasteboard		*dragPb;

//    NSLog(@"prepareForDragOperation called");

  dragPb = [sender draggingPasteboard];

  types = [dragPb types];
  
  if ([types containsObject: IBViewPboardType] == YES)
    {
      dragType = IBViewPboardType;
    }
  else if ([types containsObject: GormLinkPboardType] == YES)
    {
      dragType = GormLinkPboardType;
    }
  else if ([types containsObject: IBFormatterPboardType] == YES)
    {
      dragType = IBFormatterPboardType;
    }
  else
    {
      dragType = nil;
    }

  if (dragType == IBViewPboardType)
    {
      /*
       * We can accept views dropped anywhere.
       */
      NSPoint		loc = [sender draggingLocation];
      loc = [_editedObject  
	      convertPoint: loc fromView: nil];
      if (NSMouseInRect(loc, [_editedObject bounds], NO) == NO)
	{
	  return NO;
	}
      
      return YES;
    }
  
  return NO;
}

- (BOOL) performDragOperation: (id<NSDraggingInfo>)sender
{
  NSString		*dragType;
  NSPasteboard		*dragPb;
  NSArray *types;

  dragPb = [sender draggingPasteboard];

  types = [dragPb types];
  
  if ([types containsObject: IBViewPboardType] == YES)
    {
      dragType = IBViewPboardType;
    }
  else if ([types containsObject: GormLinkPboardType] == YES)
    {
      dragType = GormLinkPboardType;
    }
  else if ([types containsObject: IBFormatterPboardType] == YES)
    {
      dragType = IBFormatterPboardType;
    }
  else
    {
      dragType = nil;
    }

  if (dragType == IBViewPboardType)
    {
      NSPoint		loc = [sender draggingLocation];
      NSArray		*views;
      NSEnumerator	*enumerator;
      NSView		*sub;

      /*
      if (opened != YES)
	{
	  NSLog(@"make ourself the editor");
	}
      else if (openedSubeditor != nil)
	{
	  NSLog(@"close our subeditors");
	}
      */

      /*
       * Ask the document to get the dragged views from the pasteboard and add
       * them to it's collection of known objects.
       */
      views = [document pasteType: IBViewPboardType
		   fromPasteboard: dragPb
			   parent: _editedObject];
      /*
       * Now make all the views subviews of ourself, setting their origin to
       * be the point at which they were dropped (converted from window
       * coordinates to our own coordinates).
       */
      loc = [_editedObject convertPoint: loc fromView: nil];
      if (NSMouseInRect(loc, [_editedObject bounds], NO) == NO)
	{
	  // Dropped outside our view frame
	  NSLog(@"Dropped outside current edit view");
	  dragType = nil;
	  return NO;
	}
      enumerator = [views objectEnumerator];
      while ((sub = [enumerator nextObject]) != nil)
	{
	  NSRect	rect = [sub frame];
	  
	  rect.origin = [_editedObject
			  convertPoint: [sender draggedImageLocation]
			  fromView: nil];
	  rect.origin.x = (int) rect.origin.x;
	  rect.origin.y = (int) rect.origin.y;
	  rect.size.width = (int) rect.size.width;
	  rect.size.height = (int) rect.size.height;
	  [sub setFrame: rect];

	  [_editedObject addSubview: sub];
	  
	  {
	    id editor;
//  	    NSLog(@"sub %@ %@", sub, [sub editorClassName]);
	    editor = [document editorForObject: sub 
			       inEditor: self 
			       create: YES];
//  	    NSLog(@"editor %@", editor);
	    [self selectObjects: 
		    [NSArray arrayWithObject: editor]];
	  }
	}
      // FIXME  we should maybe open ourself
    }

  return YES;
}


- (void) pasteInSelection
{
  [self pasteInView: _editedObject];
}

@class GormBoxEditor;

//  - (void) ungroupSelf
//  {
//    if ([parent isKindOfClass: [GormBoxEditor class]]
//        && [[parent parent] isKindOfClass: 
//  			    [GormViewWithContentViewEditor class]])
//      {
//        NSEnumerator *enumerator;
//        GormViewEditor *subview;
//        enumerator = [[_editedObject subviews] objectEnumerator];
//        NSMutableArray *newSelection = [NSMutableArray array];

//        [[parent parent] makeSubeditorResign];

//        while ((subview = [enumerator nextObject]) != nil)
//  	{
//  	  id v;
//  	  NSRect frame;
//  	  v = [subview editedObject];
//  	  frame = [v frame];
//  	  frame = [[parent parent] convertRect: frame
//  				   fromView: _editedObject];
//  	  [subview deactivate];
	  
//  	  [[[parent parent] editedObject] addSubview: v];
//  	  [v setFrame: frame];
//  	  [subview close];
//  	  [newSelection addObject: 
//  			 [document editorForObject: v
//  				   inEditor: [parent parent]
//  				   create: YES]];
//  	}
//        [[parent parent] selectObjects: newSelection];

//        {
//  	id thisBox = [parent editedObject];
//  	[parent close];
//  	[thisBox removeFromSuperview];

//        }
//      }
//  }

@class GormSplitViewEditor;

- (NSArray *)destroyAndListSubviews
{
  if ([parent isKindOfClass: [GormBoxEditor class]]
      && 
      ([[parent parent] isKindOfClass: 
			    [GormViewWithContentViewEditor class]]
       || [[parent parent] isKindOfClass: 
			     [GormSplitViewEditor class]]))
    {
      NSEnumerator *enumerator = [[_editedObject subviews] objectEnumerator];
      GormViewEditor *subview;
      NSMutableArray *newSelection = [NSMutableArray array];

      [[parent parent] makeSubeditorResign];

      while ((subview = [enumerator nextObject]) != nil)
	{
	  id v;
	  NSRect frame;
	  v = [subview editedObject];
	  frame = [v frame];
	  frame = [[parent parent] convertRect: frame
				   fromView: _editedObject];
	  [subview deactivate];
	  
	  [v setFrame: frame];
//  	  [[[parent parent] editedObject] addSubview: v];
	  [newSelection addObject: v];
	}

      {
	id thisView = [parent editedObject];
	[parent close];
	[thisView removeFromSuperview];

      }
      
      return newSelection;
    }
  return nil;
}

- (void) deleteSelection: (id) sender
{
  [self deleteSelection];
}

@end