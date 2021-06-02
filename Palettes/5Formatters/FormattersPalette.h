/* DataPalette - Formatter Additions...

   Copyright (C) 2021 Free Software Foundation, Inc.

   Author:  Gregory Casamento <greg.casamento@gmail.com>
   Date: June 1 2021
   
   This file is part of GNUstep.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/

#ifndef INCLUDED_DataPalette_h
#define INCLUDED_DataPalette_h

#include <Foundation/Foundation.h>
#include <InterfaceBuilder/InterfaceBuilder.h>

/*
 * NSDateFormatter and NSNumberFormatter extensions
 * for Gorm Formatters used in the Data Palette
 */

@interface NSDateFormatter (GormAdditions)

+ (int) formatCount;
+ (NSString *) formatAtIndex: (int)index;
+ (NSInteger) indexOfFormat: (NSString *) format;
+ (NSString *) defaultFormat;
+ (id) defaultFormatValue;

@end

@interface NSNumberFormatter (GormAdditions)

+ (int) formatCount;
+ (NSString *) formatAtIndex: (int)index;
+ (NSString *) positiveFormatAtIndex: (int)index;
+ (NSString *) zeroFormatAtIndex: (int)index;
+ (NSString *) negativeFormatAtIndex: (int)index;
+ (NSDecimalNumber *) positiveValueAtIndex: (int)index;
+ (NSDecimalNumber *) negativeValueAtIndex: (int)index;
+ (NSInteger) indexOfFormat: (NSString *)format;
+ (NSString *) defaultFormat;
+ (id) defaultFormatValue;
- (NSString *) zeroFormat;

@end

@interface FormattersPalette: IBPalette <IBViewResourceDraggingDelegates>
@end

#endif

