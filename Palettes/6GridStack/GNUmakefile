#   GNUmakefile 
#
#   Copyright (C) 1999 Free Software Foundation, Inc.
#
#   Author:  Laurent Julliard <laurent@julliard-online.org>
#   Date: Nov 2001
#   
#   This file is part of GNUstep.
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

PACKAGE_NAME = gorm
include $(GNUSTEP_MAKEFILES)/common.make

PALETTE_NAME = 6GridStack
6GridStack_PALETTE_ICON = GridStackPalette
6GridStack_PRINCIPAL_CLASS = GridStackPalette

6GridStack_OBJC_FILES = \
	GridStackPalette.m

6GridStack_RESOURCE_FILES = GridStackPalette.tiff \
	stack_view.tiff \
	grid_view.tiff \
	palette.table

6GridStack_STANDARD_INSTALL = no

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/palette.make

#-include GNUmakefile.postamble

