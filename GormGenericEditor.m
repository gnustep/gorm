#include "GormPrivate.h"

@implementation	GormGenericEditor

- (id) editorForDocument: (id<IBDocuments>)aDocument
{
  return [[self class] editorForDocument: aDocument];
}


- (void) setEditor: (id)editor
       forDocument: (id<IBDocuments>)aDocument
{
  [[self class] setEditor: editor
		     forDocument: aDocument];
}

- (BOOL) acceptsFirstMouse: (NSEvent*)theEvent
{
  return YES;   /* Ensure we get initial mouse down event.      */
}

- (BOOL) activate
{
  [[self window] makeKeyAndOrderFront: self];
  return YES;
}

- (void) addObject: (id)anObject
{
  if (anObject != nil
    && [objects indexOfObjectIdenticalTo: anObject] == NSNotFound)
    {
//        NSNotificationCenter	*nc;
//        nc = [NSNotificationCenter defaultCenter];
      [objects addObject: anObject];
      [self refreshCells];
    }
}

- (void) mouseDown: (NSEvent*)theEvent
{
  if ([theEvent modifierFlags] & NSControlKeyMask)
    {
      NSPoint	loc = [theEvent locationInWindow];
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
    }

  [super mouseDown: theEvent];
}


- (id) changeSelection: (id)sender
{
  int	row = [self selectedRow];
  int	col = [self selectedColumn];
  int	index = row * [self numberOfColumns] + col;
  id	obj = nil;

  if (index >= 0 && index < [objects count])
    {
      obj = [objects objectAtIndex: index];
      [self selectObjects: [NSArray arrayWithObject: obj]];
    }
  return obj;
}

- (BOOL) containsObject: (id)object
{
  if ([objects indexOfObjectIdenticalTo: object] == NSNotFound)
    return NO;
  return YES;
}

- (void) close
{
  [self deactivate];
  [self closeSubeditors];
}

// Stubbed out methods...  Since this is an abstract class, some methods need to be
// provided so that compilation will occur cleanly and to give a warning if called.
- (void) closeSubeditors
{
}

- (void) resetObject: (id)object
{
}

- (id) initWithObject: (id)anObject inDocument: (id<IBDocuments>)aDocument
{
  return self;
}

- (BOOL) acceptsTypeFromArray: (NSArray*)types
{
  return NO;
}

- (void) makeSelectionVisible: (BOOL)flag
{
}

- (void) deactivate
{
}

- (void) copySelection
{
}

- (void) pasteInSelection
{
}
// end of stubbed methods...

- (void) dealloc
{
  RELEASE(objects);
  [super dealloc];
}

- (void) deleteSelection
{
  if (selected != nil)
    {
      [document detachObject: selected];
      [objects removeObjectIdenticalTo: selected];
      [self selectObjects: [NSArray array]];
      [self refreshCells];
    }
}

- (id<IBDocuments>) document
{
  return document;
}

- (id) editedObject
{
  return selected;
}

- (id<IBEditors>) openSubeditorForObject: (id)anObject
{
  return nil;
}

- (void) orderFront
{
  [[self window] orderFront: self];
}


/*
 * Return the rectangle in which an objects image will be displayed.
 * (use window coordinates)
 */
- (NSRect) rectForObject: (id)anObject
{
  unsigned	pos = [objects indexOfObjectIdenticalTo: anObject];
  NSRect	rect;
  int		r;
  int		c;

  if (pos == NSNotFound)
    return NSZeroRect;
  r = pos / [self numberOfColumns];
  c = pos % [self numberOfColumns];
  rect = [self cellFrameAtRow: r column: c];
  /*
   * Adjust to image area.
   */
//    rect.size.width -= 15;
  rect.size.height -= 15;
  rect = [self convertRect: rect toView: nil];
  return rect;
}


- (void) refreshCells
{
  unsigned	count = [objects count];
  unsigned	index;
  int		cols = 0;
  int		rows;
  int		width;

  width = [[self superview] bounds].size.width;
  while (width >= 72)
    {
      width -= (72 + 8);
      cols++;
    }
  if (cols == 0)
    {
      cols = 1;
    }
  rows = count / cols;
  if (rows == 0 || rows * cols != count)
    {
      rows++;
    }
  [self renewRows: rows columns: cols];

  for (index = 0; index < count; index++)
    {
      id		obj = [objects objectAtIndex: index];
      NSButtonCell	*but = [self cellAtRow: index/cols column: index%cols];

      [but setImage: [obj imageForViewer]];
      [but setTitle: [document nameForObject: obj]];
      [but setShowsStateBy: NSChangeGrayCellMask];
      [but setHighlightsBy: NSChangeGrayCellMask];
    }
  while (index < rows * cols)
    {
      NSButtonCell	*but = [self cellAtRow: index/cols column: index%cols];

      [but setImage: nil];
      [but setTitle: @""];
      [but setShowsStateBy: NSNoCellMask];
      [but setHighlightsBy: NSNoCellMask];
      index++;
    }
  [self setIntercellSpacing: NSMakeSize(8,8)];
  [self sizeToCells];
  [self setNeedsDisplay: YES];
}

- (void) removeObject: (id)anObject
{
  unsigned	pos;

  pos = [objects indexOfObjectIdenticalTo: anObject];
  if (pos == NSNotFound)
    {
      return;
    }
  [objects removeObjectAtIndex: pos];
  [self refreshCells];
}

- (void) resizeWithOldSuperviewSize: (NSSize)oldSize
{
  [self refreshCells];
}

- (NSArray*) selection
{
  if (selected == nil)
    return [NSArray array];
  else
    return [NSArray arrayWithObject: selected];
}

- (unsigned) selectionCount
{
  return (selected == nil) ? 0 : 1;
}


- (BOOL) wantsSelection
{
  return NO;
}

- (NSWindow*) window
{
  return [super window];
}

- (void) selectObjects: (NSArray*)anArray
{
  id	obj = [anArray lastObject];

  selected = obj;
  [document setSelectionFromEditor: self];
  [self makeSelectionVisible: YES];
}
@end