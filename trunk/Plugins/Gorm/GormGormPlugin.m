/* GormNibModule.m
 *
 * Copyright (C) 2007 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	2007
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
 */

#include <GormCore/GormPlugin.h>
#include <GormCore/GormWrapperLoader.h>
#include <Foundation/NSArray.h>
#include "GormGormWrapperLoader.h"

@interface GormGormPlugin : GormPlugin
@end

@implementation GormGormPlugin
- (void) didLoad
{
  [self registerDocumentTypeName: [GormGormWrapperLoader fileType]
	humanReadableName: @"GNUstep Gorm"
	forExtensions: [NSArray arrayWithObjects: @"gorm",nil]];
}
@end

