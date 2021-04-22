/* All rights reserved */

#include <AppKit/AppKit.h>

#include "GormNSSplitViewInspector.h"

@implementation NSSplitView (IBObjectAdditions)
- (NSString *) inspectorClassName
{
  return @"GormNSSplitViewInspector";
}

- (NSString*) editorClassName
{
  return @"GormSplitViewEditor";
}
@end

@implementation GormNSSplitViewInspector

- init
{
  self = [super init];
  if (self != nil)
    {
      if ([NSBundle loadNibNamed: @"GormNSSplitViewInspector" 
		    owner: self] == NO)
	{
	  
	  NSDictionary	*table;
	  NSBundle	*bundle;
	  table = [NSDictionary dictionaryWithObject: self forKey: @"NSOwner"];
	  bundle = [NSBundle mainBundle];
	  if ([bundle loadNibFile: @"GormNSSplitViewInspector"
		      externalNameTable: table
		      withZone: [self zone]] == NO)
	    {
	      NSLog(@"Could not open gorm GormNSSplitViewInspector");
	      NSLog(@"self %@", self);
	      return nil;
	    }
	}
    }

  return self;
}

- (void)awakeFromNib
{
  NSEnumerator *en = [orientation objectEnumerator];
  NSCell *cell = nil;
  while ((cell = [en nextObject]) != nil)
    {
      [cell setRefusesFirstResponder: YES];
    }
}

- (void) _getValuesFromObject
{
  BOOL state = [(NSSplitView *)object isVertical];
  // get the values from the object
  if(state == NO)
    {
      [orientation selectCellAtRow: 0 column: 0];
    }
  else
    {
      [orientation selectCellAtRow: 1 column: 0];      
    }
}

- (void) setObject: (id)anObject
{
  [super setObject: anObject];
  [self _getValuesFromObject];
}

- (void) ok: (id)sender
{
  id cell = nil;
  BOOL state = NO;

  // horizontal switch..  if it's active/inactive we 
  // know what the selection is.
  [super ok: sender];
  cell = [orientation cellAtRow: 0 column: 0];
  state = ([cell state] == NSOnState)?NO:YES;
  [object setVertical: state];
  [object adjustSubviews];
}
@end
