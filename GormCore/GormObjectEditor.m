/* GormObjectEditor.m
 *
 * Copyright (C) 1999 Free Software Foundation, Inc.
 *
 * Author:	Richard Frith-Macdonald <richard@brainstrom.co.uk>
 * Date:	1999
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

#include "GormPrivate.h"
#include "GormFunctions.h"
#include <InterfaceBuilder/IBObjectAdditions.h>

/*
 * Method to return the image that should be used to display objects within
 * the matrix containing the objects in a document.
 */
@interface NSObject (GormObjectAdditions)
@end

@implementation NSObject (GormObjectAdditions)
- (NSImage*) imageForViewer
{
  static NSImage	*image = nil;

  if (image == nil)
    {
      NSBundle	*bundle = [NSBundle mainBundle];
      NSString *path = [bundle pathForImageResource: @"GormUnknown"]; 
      image = [[NSImage alloc] initWithContentsOfFile: path];
    }

  return image;
}

- (NSString*) inspectorClassName
{
  return @"GormObjectInspector";
}

- (NSString*) connectInspectorClassName
{
  return @"GormConnectionInspector";
}

- (NSString*) sizeInspectorClassName
{
  return @"GormNotApplicableInspector";
}

- (NSString*) helpInspectorClassName
{
  return @"GormNotApplicableInspector";
}

- (NSString*) classInspectorClassName
{
  return @"GormCustomClassInspector";
}

- (NSString*) editorClassName
{
  return @"GormObjectEditor";
}
@end

@implementation	GormObjectEditor

static NSMapTable	*docMap = 0;

+ (void) initialize
{
  if (self == [GormObjectEditor class])
    {
      docMap = NSCreateMapTable(NSObjectMapKeyCallBacks,
				NSObjectMapValueCallBacks, 
				2);
    }
}

+ (id) editorForDocument: (id<IBDocuments>)aDocument
{
  id	editor = NSMapGet(docMap, (void*)aDocument);

  if (editor == nil)
    {
      editor = [[self alloc] initWithObject: nil inDocument: aDocument];
      AUTORELEASE(editor);
    }
  return editor;
}

+ (void) setEditor: (id)editor
       forDocument: (id<IBDocuments>)aDocument
{
  NSMapInsert(docMap, (void*)aDocument, (void*)editor);
}


- (BOOL) acceptsTypeFromArray: (NSArray*)types
{
  if ([types containsObject: IBObjectPboardType] == YES)
    return YES;
  return NO;
}

- (void) pasteInSelection
{
}

- (void) copySelection
{
  if (selected != nil)
    {
      [document copyObjects: [self selection]
		       type: IBViewPboardType
	       toPasteboard: [NSPasteboard generalPasteboard]];
    }
}

- (void) deleteSelection
{
  if (selected != nil
      && [[document nameForObject: selected] isEqualToString: @"NSOwner"] == NO
      && [[document nameForObject: selected] isEqualToString: @"NSFirst"] == NO)
    {
      NSNotificationCenter	*nc;

      nc = [NSNotificationCenter defaultCenter];

      if ([selected isKindOfClass: [NSMenu class]] &&
	  [[document nameForObject: selected] isEqual: @"NSMenu"] == YES)
	{
	  NSString *title = _(@"Removing Main Menu");
	  NSString *msg = _(@"Are you sure you want to do this?");
	  int retval = NSRunAlertPanel(title, msg,_(@"OK"),_(@"Cancel"), nil, nil);
	  
	  // if the user *really* wants to delete the menu, do it.
	  if(retval != NSAlertDefaultReturn)
	    return;
	}

      [document detachObject: selected];
      if ([selected isKindOfClass: [NSWindow class]] == YES)
	{
	  NSArray *subviews = allSubviews([selected contentView]);
	  [document detachObjects: subviews];
	  [selected close];
	}
      
      if ([selected isKindOfClass: [NSMenu class]] == YES)
	{
	  NSArray *items = findAll( selected );
	  NSEnumerator *en = [items objectEnumerator];
	  id obj = nil;
	  
	  while((obj = [en nextObject]) != nil)
	    {
	      [document detachObject: obj];
	    }
	}
      
      [objects removeObjectIdenticalTo: selected];
      [self selectObjects: [NSArray array]];
      [self refreshCells];
    }
}

- (void) removeAllInstancesOfClass: (NSString *)className
{
  GormClassManager *classManager = [(GormDocument *)document classManager];
  NSMutableArray *removedObjects = [NSMutableArray array];
  NSEnumerator *en = [objects objectEnumerator];
  id object = nil;

  // locate objects for removal
  while((object = [en nextObject]) != nil)
    {
      NSString *clsForObj = [classManager classNameForObject: object];
      if([className isEqual: clsForObj])
	{
	  [removedObjects addObject: object];
	}
    }

  // remove the objects
  [document detachObjects: removedObjects];
}

/*
 *	Dragging source protocol implementation
 */
- (void) draggedImage: (NSImage*)i endedAt: (NSPoint)p deposited: (BOOL)f
{
}

- (unsigned) draggingEntered: (id<NSDraggingInfo>)sender
{
  NSArray	*types;

  dragPb = [sender draggingPasteboard];
  types = [dragPb types];
  if ([types containsObject: IBObjectPboardType] == YES)
    {
      dragType = IBObjectPboardType;
    }
  else if ([types containsObject: GormLinkPboardType] == YES)
    {
      dragType = GormLinkPboardType;
    }
  else
    {
      dragType = nil;
    }
  return [self draggingUpdated: sender];
}

- (unsigned) draggingUpdated: (id<NSDraggingInfo>)sender
{
  if (dragType == IBObjectPboardType)
    {
      return NSDragOperationCopy;
    }
  else if (dragType == GormLinkPboardType)
    {
      NSPoint	loc = [sender draggingLocation];
      int	r, c;
      int	pos;
      id	obj = nil;

      loc = [self convertPoint: loc fromView: nil];
      [self getRow: &r column: &c forPoint: loc];
      pos = r * [self numberOfColumns] + c;
      if (pos >= 0 && pos < [objects count])
	{
	  obj = [objects objectAtIndex: pos];
	}
      if (obj == [NSApp connectSource])
	{
	  return NSDragOperationNone;	/* Can't drag an object onto itsself */
	}
      [NSApp displayConnectionBetween: [NSApp connectSource] and: obj];
      if (obj != nil)
	{
	  return NSDragOperationLink;
	}
      else
	{
	  return NSDragOperationNone;
	}
    }
  else
    {
      return NSDragOperationNone;
    }
}

- (unsigned int) draggingSourceOperationMaskForLocal: (BOOL)flag
{
  return NSDragOperationLink;
}

- (void) drawSelection
{
}

- (void) handleNotification: (NSNotification*)aNotification
{
  NSString *name = [aNotification name];

  if([name isEqual: GormResizeCellNotification])
    {
      NSDebugLog(@"Recieved notification");
      [self setCellSize: defaultCellSize()];
    }
}

/*
 *	Initialisation - register to receive DnD with our own types.
 */
- (id) initWithObject: (id)anObject inDocument: (id<IBDocuments>)aDocument
{
  id	old = NSMapGet(docMap, (void*)aDocument);

  if (old != nil)
    {
      RELEASE(self);
      self = RETAIN(old);
      [self addObject: anObject];
      return self;
    }

  self = [super initWithObject: anObject inDocument: aDocument];
  if (self != nil)
    {
      NSButtonCell	*proto;

      document = aDocument;

      [self registerForDraggedTypes: [NSArray arrayWithObjects:
	IBObjectPboardType, GormLinkPboardType, nil]];

      [self setAutosizesCells: NO];
      [self setCellSize: defaultCellSize()];
      [self setIntercellSpacing: NSMakeSize(8,8)];
      [self setAutoresizingMask: NSViewMinYMargin|NSViewWidthSizable];
      [self setMode: NSRadioModeMatrix];
      /*
       * Send mouse click actions to self, so we can handle selection.
       */
      [self setAction: @selector(changeSelection:)];
      [self setDoubleAction: @selector(raiseSelection:)];
      [self setTarget: self];

      objects = [NSMutableArray new];
      proto = [NSButtonCell new];
      [proto setBordered: NO];
      [proto setAlignment: NSCenterTextAlignment];
      [proto setImagePosition: NSImageAbove];
      [proto setSelectable: NO];
      [proto setEditable: NO];
      [self setPrototype: proto];
      RELEASE(proto);
      [self setEditor: self
	    forDocument: aDocument];
      [self addObject: anObject];

      // set up the notification...
      [[NSNotificationCenter defaultCenter]
	addObserver: self
	selector: @selector(handleNotification:)
	name: GormResizeCellNotification
	object: nil];
    }
  return self;
}

- (void) close
{
  [super close];
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  NSMapRemove(docMap,document);
}

- (void) makeSelectionVisible: (BOOL)flag
{
  if (flag == YES && selected != nil)
    {
      unsigned	pos = [objects indexOfObjectIdenticalTo: selected];
      int	r = pos / [self numberOfColumns];
      int	c = pos % [self numberOfColumns];

      [self selectCellAtRow: r column: c];
    }
  else
    {
      [self deselectAllCells];
    }
  [self displayIfNeeded];
  [[self window] flushWindow];
}

- (void) mouseDown: (NSEvent*)theEvent
{
  if ([theEvent modifierFlags] & NSControlKeyMask)
    {
      NSPoint	loc = [theEvent locationInWindow];
      NSString	*name;
      int	r = 0, c = 0;
      int	pos = 0;
      id	obj = nil;

      loc = [self convertPoint: loc fromView: nil];
      [self getRow: &r column: &c forPoint: loc];
      pos = r * [self numberOfColumns] + c;
      if (pos >= 0 && pos < [objects count])
	{
	  obj = [objects objectAtIndex: pos];
	}
      if (obj != nil && obj != selected)
	{
	  [self selectObjects: [NSArray arrayWithObject: obj]];
	  [self makeSelectionVisible: YES];
	}
      name = [document nameForObject: obj];
      if ([name isEqualToString: @"NSFirst"] == NO && name != nil)
	{
	  NSPasteboard	*pb;

	  pb = [NSPasteboard pasteboardWithName: NSDragPboard];
	  [pb declareTypes: [NSArray arrayWithObject: GormLinkPboardType]
		     owner: self];
	  [pb setString: name forType: GormLinkPboardType];
	  [NSApp displayConnectionBetween: obj and: nil];

	  [self dragImage: [NSApp linkImage]
		       at: loc
		   offset: NSZeroSize
		    event: theEvent
	       pasteboard: pb
		   source: self
		slideBack: YES];
	  [self makeSelectionVisible: YES];
	  return;
	}
    }

  [super mouseDown: theEvent];
}

- (BOOL) performDragOperation: (id<NSDraggingInfo>)sender
{
  if (dragType == IBObjectPboardType)
    {
      NSArray		*array;
      NSEnumerator	*enumerator;
      id		obj;

      /*
       * Ask the document to get the dragged objects from the pasteboard and
       * add them to it's collection of known objects.
       */
      array = [document pasteType: IBObjectPboardType
		   fromPasteboard: dragPb
			   parent: [objects objectAtIndex: 0]];
      enumerator = [array objectEnumerator];
      while ((obj = [enumerator nextObject]) != nil)
	{
	  RETAIN(obj);  // FIXME: This will probably leak...
	  [[(GormDocument *)document topLevelObjects] addObject: obj];
	  [self addObject: obj];
	}
      return YES;
    }
  else if (dragType == GormLinkPboardType)
    {
      NSPoint	loc = [sender draggingLocation];
      int	r, c;
      int	pos;
      id	obj = nil;

      loc = [self convertPoint: loc fromView: nil];
      [self getRow: &r column: &c forPoint: loc];
      pos = r * [self numberOfColumns] + c;
      if (pos >= 0 && pos < [objects count])
	{
	  obj = [objects objectAtIndex: pos];
	}
      if (obj == nil)
	{
	  return NO;
	}
      else
	{
	  [NSApp displayConnectionBetween: [NSApp connectSource] and: obj];
	  [NSApp startConnecting];
	  return YES;
	}
    }
  else
    {
      NSLog(@"Drop with unrecognized type!");
      return NO;
    }
}

- (BOOL) prepareForDragOperation: (id<NSDraggingInfo>)sender
{
  /*
   * Tell the source that we will accept the drop if we can.
   */
  if (dragType == IBObjectPboardType)
    {
      /*
       * We can accept objects dropped anywhere.
       */
      return YES;
    }
  else if (dragType == GormLinkPboardType)
    {
      NSPoint	loc = [sender draggingLocation];
      int	r, c;
      int	pos;
      id	obj = nil;

      loc = [self convertPoint: loc fromView: nil];
      [self getRow: &r column: &c forPoint: loc];
      pos = r * [self numberOfColumns] + c;
      if (pos >= 0 && pos < [objects count])
	{
	  obj = [objects objectAtIndex: pos];
	}
      if (obj != nil)
	{
	  return YES;
	}
    }
  return NO;
}

- (id) raiseSelection: (id)sender
{
  id	obj = [self changeSelection: sender];
  id	e;

  if(obj != nil)
    {
      e = [document editorForObject: obj create: YES];
      [e orderFront];
      [e resetObject: obj];
    }

  return self;
}

- (void) resetObject: (id)anObject
{
  NSString		*name = [document nameForObject: anObject];
  GormInspectorsManager	*mgr = [(id<Gorm>)NSApp inspectorsManager];

  if ([name isEqual: @"NSOwner"] == YES)
    {
      [mgr setClassInspector];
    }
  if ([name isEqual: @"NSFirst"] == YES)
    {
      [mgr setClassInspector];
    }
}
@end


