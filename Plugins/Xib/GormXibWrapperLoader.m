/* GormXibWrapperLoader
 *
 * Copyright (C) 2010, 2021 Free Software Foundation, Inc.
 *
 * Author:      Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:        2010, 2021
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include <GormCore/GormCore.h>

#include "GormXibWrapperLoader.h"

/*
 * Forward declarations for classes
 */
@class GormNSWindow;

/*
 * This allows us to retrieve the customClasses from the XIB unarchiver.
 */
@interface NSKeyedUnarchiver (Private)
- (NSArray *) customClasses;
- (NSDictionary *) decoded;
@end

/*
 * Xib loader...
 */
@implementation GormXibWrapperLoader
+ (NSString *) fileType
{
  return @"GSXibFileType";
}

- (id) _replaceProxyInstanceWithRealObject: (id)obj
{
  if ([obj isKindOfClass: [GormObjectProxy class]])
    {
      if ([[obj className] isEqualToString: @"NSApplication"])
        {
          return [document filesOwner];
        }

      if ([[obj className] isEqualToString: @"FirstResponder"])
        {
          return [document firstResponder];
        }
    }
  else if (obj == nil)
    {
      return [document firstResponder];
    }
  return obj;
}

- (BOOL) loadFileWrapper: (NSFileWrapper *)wrapper withDocument: (GormDocument *) doc
{
  BOOL result = NO;

  NS_DURING
    {
      GormPalettesManager       *palettesManager = [(id<Gorm>)NSApp palettesManager];
      NSDictionary              *substituteClasses = [palettesManager substituteClasses];
      NSString                  *subClassName = nil;
      GormClassManager          *classManager = [doc classManager];

      if ([super loadFileWrapper: wrapper 
                    withDocument: doc] &&
	  [wrapper isDirectory] == NO)
	{
	  NSData *data = [wrapper regularFileContents];
	  id docFilesOwner;

	  // turn off custom classes...
	  [NSClassSwapper setIsInInterfaceBuilder: YES];	  
	  
	  // check the data...
	  if (data == nil) 
	    {
	      result = NO;
	    }
	  else
	    {
              NSEnumerator *en;
              NSKeyedUnarchiver *u; // using superclass for its interface.

	      //
	      // Create an unarchiver, and use it to unarchive the xib file while
	      // handling class replacement so that standard objects understood
	      // by the gui library are converted to their Gorm internal equivalents.
	      //
	      u = [GSXibKeyedUnarchiver unarchiverForReadingWithData: data];
	      [u setDelegate: self];
	      
	      //
	      // Special internal classes
	      // 
	      [u setClass: [GormObjectProxy class]
		 forClassName: @"NSCustomObject"];
	      [u setClass: [GormObjectProxy class]
		 forClassName: @"NSCustomObject5"];
	      [u setClass: [GormCustomView class] 
		 forClassName: @"NSCustomView"];
	      [u setClass: [GormWindowTemplate class] 
		 forClassName: @"NSWindowTemplate"];
	      [u setClass: [GormNSWindow class] 
		 forClassName: @"NSWindow"];
              [u setClass: [IBUserDefinedRuntimeAttribute class]
                 forClassName: @"IBUserDefinedRuntimeAttribute5"];
	      
	      //
	      // Substitute any classes specified by the palettes...
	      //
	      en = [substituteClasses keyEnumerator];
	      while ((subClassName = [en nextObject]) != nil)
		{
		  NSString *realClassName = [substituteClasses objectForKey: subClassName];
		  Class substituteClass = NSClassFromString(subClassName);
		  [u setClass: substituteClass
		     forClassName: realClassName];
		}
	      
	      //
	      // decode
	      //
	      container = [u decodeObjectForKey: @"IBDocument.Objects"];
	      if (container == nil || [container isKindOfClass: [IBObjectContainer class]] == NO)
		{
		  result = NO;
		}
	      else
		{
		  IBConnectionRecord *cr = nil;
                  NSArray *rootObjects = nil;
                  id xibFirstResponder = nil;

                  rootObjects = [u decodeObjectForKey: @"IBDocument.RootObjects"];
		  nibFilesOwner = [rootObjects objectAtIndex: 0];
		  xibFirstResponder = [rootObjects objectAtIndex: 1];
		  docFilesOwner = [doc filesOwner];

		  //
		  // set the current class on the File's owner...
		  //
		  if ([nibFilesOwner isKindOfClass: [GormObjectProxy class]])
		    {
		      [docFilesOwner setClassName: [nibFilesOwner className]];	  
		    }
		  
		  //
		  // add root objects...
		  //
		  en = [rootObjects objectEnumerator];
                  id obj = nil;
		  while ((obj = [en nextObject]) != nil)
		    {
		      NSString *customClassName = nil;
		      NSString *objName = nil;
		      
		      // skip the file's owner, it is handled above...
		      if ((obj == nibFilesOwner) || (obj == xibFirstResponder))
                        {
                          continue;
                        }

                      //
                      // If it's NSApplication (most likely the File's Owner)
                      // skip it...
                      //
                      if ([obj isKindOfClass: [GormObjectProxy class]])
                        {
                          if ([[obj className] isEqualToString: @"NSApplication"])
                            {
                              continue;
                            }

                          customClassName = [obj className];
                        }
                      
		      //
		      // if it's a window template, then replace it with an
                      // actual window.
		      //
                      id o = nil;
		      if ([obj isKindOfClass: [GormWindowTemplate class]])
			{
			  NSString *className = [obj className];
			  BOOL isDeferred = [obj isDeferred];
			  BOOL isVisible = YES;
                          
			  // make the object deferred/visible...
			  o = [obj nibInstantiate];
                          
			  [doc setObject: o isDeferred: isDeferred];
			  [doc setObject: o isVisibleAtLaunch: isVisible];

                          // Add to the document...
                          [doc attachObject: o
                                   toParent: nil];
                          
			  // record the custom class...
			  if ([classManager isCustomClass: className])
			    {
			      customClassName = className;
			    }
			}
		      
		      if ([rootObjects containsObject: obj] && obj != nil &&
                          [obj isKindOfClass: [GormWindowTemplate class]] == NO)
			{
                          NSLog(@"obj = %@",obj);
                          [doc attachObject: obj
                                   toParent: nil];
                        }
                      
		      if (customClassName != nil)
			{
			  objName = [doc nameForObject: obj];
                          if (objName != nil)
                            {
                              [classManager setCustomClass: customClassName
                                                   forName: objName];
                            }
                        }
                    }
		  
		  //
		  // Add custom classes...
		  //
                  NSArray *customClasses = [u customClasses];
                  NSEnumerator *en = [customClasses objectEnumerator];
                  NSDictionary *customClassDict = nil;
                  NSDictionary *decoded = [u decoded];
                  
                  NSDebugLog(@"customClasses = %@", customClasses);
                  while ((customClassDict = [en nextObject]) != nil)
                    {
                      NSString *theId = [customClassDict objectForKey: @"id"];
                      NSString *customClassName = [customClassDict objectForKey: @"customClassName"];
                      NSString *parentClassName = [customClassDict objectForKey: @"parentClassName"];
                      id realObject = [decoded objectForKey: theId];
                      NSString *theName = nil;

                      realObject = [self _replaceProxyInstanceWithRealObject: realObject];
                      NSDebugLog(@"realObject = %@", realObject);
                      
                      if ([doc containsObject: realObject])
                        {
                          theName = [doc nameForObject: realObject];
                          NSDebugLog(@"Found name = %@ for realObject = %@", theName, realObject);
                        }
                      else
                        {
                          NSDebugLog(@"realObject = %@ has no name in document", realObject);
                          continue;
                        }
                      
                      if ([parentClassName isEqualToString: @"NSCustomObject5"])
                        {
                          parentClassName = @"NSObject";
                        }
                      
                      NSDebugLog(@"Adding customClassName = %@ with parent className = %@", customClassName,
                            parentClassName);
                      [classManager addClassNamed: customClassName
                              withSuperClassNamed: parentClassName
                                      withActions: nil
                                      withOutlets: nil
                                         isCustom: YES];
                      
                      NSDebugLog(@"Assigning %@ as customClass = %@", theName, customClassName);
                      [classManager setCustomClass: customClassName
                                           forName: theName];
                    }
                  
		  //
		  // add connections...
		  //
		  en = [container connectionRecordEnumerator];
		  while ((cr = [en nextObject]) != nil)
		    {
		      IBConnection *conn = [cr connection];
                      
                      if ([conn respondsToSelector: @selector(nibConnector)])
                        {
                          NSNibConnector *o = [conn nibConnector];
                          
                          if (o != nil)
                            {
                              id dest = [o destination];
                              id src = [o source];

                              // Replace files owner with the document files owner for loading...
                              dest = [self _replaceProxyInstanceWithRealObject: dest];
                              src = [self _replaceProxyInstanceWithRealObject: src];
                              
                              // Reset them...
                              [o setDestination: dest];
                              [o setSource: src];

                              NSDebugLog(@"connector = %@", o);

                              if([o isKindOfClass: [NSNibControlConnector class]])
                                {
                                  NSString *tag = [o label];
                                  NSRange colonRange = [tag rangeOfString: @":"];
                                  NSUInteger location = colonRange.location;
                                  
                                  if(location == NSNotFound)
                                    {
                                      NSString *newTag = [NSString stringWithFormat: @"%@:",tag];
                                      [o setLabel: (id)newTag];
                                    }

                                  [classManager addAction: [o label]
                                                forObject: src];

                                  // If the src is the first responder, use nil since this
                                  // tells AppKit to use the First Responder chain.
                                  //if (src == [doc firstResponder])
                                  //  {
                                  //    src = nil;
                                  //  }
                                  
                                  // For control connectors these roles are reversed...
                                  [o setSource: dest];
                                  [o setDestination: src];
                                }
                              else if ([o isKindOfClass: [NSNibOutletConnector class]])
                                {
                                  [classManager addOutlet: [o label]
                                                forObject: src];
                                }
                              
                              // check src/dest for window template...
                              if ([src isKindOfClass: [NSWindowTemplate class]])
                                {
                                  id win = [src realObject];
                                  [o setSource: win];
                                }
                              
                              if ([dest isKindOfClass: [NSWindowTemplate class]])
                                {
                                  id win = [dest realObject];
                                  [o setDestination: win];
                                }
                              
                              // skip any help connectors...
                              if ([o isKindOfClass: [NSIBHelpConnector class]])
                                {
                                  continue;
                                }

                              [doc addConnector: o];
                            }
                        }
                    }
		  
		  // turn on custom classes.
		  [NSClassSwapper setIsInInterfaceBuilder: NO]; 
		  
		  // clear the changes, since we just loaded the document.
		  [doc updateChangeCount: NSChangeCleared];
		  
		  result = YES;
		}
	    }
	  [NSClassSwapper setIsInInterfaceBuilder: NO];      
	}
    }
  NS_HANDLER
    {
      NSRunAlertPanel(_(@"Problem Loading"), 
		      [NSString stringWithFormat: @"Failed to load file.  Exception: %@",[localException reason]], 
		      _(@"OK"), nil, nil);
      result = NO; 
    }
  NS_ENDHANDLER;

  // return the result.
  return result;
}

- (void) unarchiver: (NSKeyedUnarchiver *)unarchiver 
  willReplaceObject: (id)obj 
	 withObject: (id)newObj
{
  // Nothing for now...
}

- (id) unarchiver: (NSKeyedUnarchiver *)unarchiver didDecodeObject: (id)obj
{
  if ([obj isKindOfClass: [NSWindowTemplate class]])
    {
      GormClassManager *classManager = [document classManager];
      Class clz ;
      NSString *className = [obj className];
      
      if([classManager isCustomClass: className])
	{
	  className = [classManager nonCustomSuperClassOf: className];
	}
      clz = [unarchiver classForClassName: className];
      // [obj setBaseWindowClass: clz];
    }
  else if ([obj respondsToSelector: @selector(setTarget:)] &&
           [obj respondsToSelector: @selector(setAction:)] &&
           [obj isKindOfClass: [NSCell class]] == NO)
    {
      // blank the target/action for all objects.
      [obj setTarget: nil];
      [obj setAction: NULL];
    }
  return obj;
}
@end
