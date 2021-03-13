#   GNUmakefile: main makefile for GNUstep Object Relationship Modeller
#
#   Copyright (C) 1999,2002,2003 Free Software Foundation, Inc.
#
#   Author:  Gregory John Casamento <greg_casamento@yahoo.com>
#   Date: 2003
#   Author:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
#   Date: 1999
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
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA
#

PACKAGE_NAME = gorm
include $(GNUSTEP_MAKEFILES)/common.make


PACKAGE_NAME=GormCore
LIBRARY_VAR=GORMCORE
LIBRARY_NAME=GormCore
GormCore_HEADER_FILES_DIR=.
GormCore_HEADER_FILES_INSTALL_DIR=/GormCore
ADDITIONAL_INCLUDE_DIRS = -I..
srcdir = .

include ../Version

GormCore_HEADER_FILES = \
	GormCore.h \
	GormBoxEditor.h \
	GormCanvasView.h \
	GormClassEditor.h \
	GormClassInspector.h \
	GormClassManager.h \
	GormClassPanelController.h \
	GormConnectionInspector.h \
	GormControlEditor.h \
	GormCustomClassInspector.h \
	GormCustomView.h \
	GormDocument.h \
	GormDocumentController.h \
	GormDocumentWindow.h \
	GormFilePrefsManager.h \
	GormFilesOwner.h \
	GormFontViewController.h \
	GormFunctions.h \
	GormGenericEditor.h \
	GormHelpInspector.h \
	GormImage.h \
	GormImageEditor.h \
	GormImageInspector.h \
	GormInspectorsManager.h \
	GormInternalViewEditor.h \
	GormMatrixEditor.h \
	GormNSPanel.h \
	GormNSSplitViewInspector.h \
	GormNSWindow.h \
	GormNSWindowView.h \
	GormObjectEditor.h \
	GormObjectInspector.h \
	GormOpenGLView.h \
	GormOutlineView.h \
	GormPalettesManager.h \
	GormPlacementInfo.h \
	GormPlugin.h \
	GormPluginManager.h \
	GormPrivate.h \
	GormProtocol.h \
	GormResource.h \
	GormResourceEditor.h \
	GormResourceManager.h \
	GormScrollViewAttributesInspector.h \
	GormServer.h \
	GormSetNameController.h \
	GormSound.h \
	GormSoundEditor.h \
	GormSoundInspector.h \
	GormSoundView.h \
	GormSplitViewEditor.h \
	GormStandaloneViewEditor.h \
	GormViewEditor.h \
	GormViewKnobs.h \
	GormViewSizeInspector.h \
	GormViewWindow.h \
	GormViewWithContentViewEditor.h \
	GormViewWithSubviewsEditor.h \
	GormWindowEditor.h \
	GormWindowTemplate.h \
	GormWrapperBuilder.h \
	GormWrapperLoader.h \
	NSCell+GormAdditions.h \
	NSColorWell+GormExtensions.h \
	NSFontManager+GormExtensions.h \
	NSView+GormExtensions.h 

GormCore_OBJC_FILES = \
	GormBoxEditor.m \
	GormCanvasView.m \
	GormClassEditor.m \
	GormClassInspector.m \
	GormClassManager.m \
	GormClassPanelController.m \
	GormConnectionInspector.m \
	GormControlEditor.m \
	GormCustomClassInspector.m \
	GormCustomView.m \
	GormDocument.m \
	GormDocumentController.m \
	GormDocumentWindow.m \
	GormFilePrefsManager.m \
	GormFilesOwner.m \
	GormFontViewController.m \
	GormFunctions.m \
	GormGenericEditor.m \
	GormHelpInspector.m \
	GormImage.m \
	GormImageEditor.m \
	GormImageInspector.m \
	GormInspectorsManager.m \
	GormInternalViewEditor.m \
	GormMatrixEditor.m \
	GormNSPanel.m \
	GormNSSplitViewInspector.m \
	GormNSWindow.m \
	GormNSWindowView.m \
	GormObjectEditor.m \
	GormObjectInspector.m \
	GormOpenGLView.m \
	GormOutlineView.m \
	GormPalettesManager.m \
	GormPlugin.m \
	GormPluginManager.m \
	GormResource.m \
	GormResourceEditor.m \
	GormResourceManager.m \
	GormScrollViewAttributesInspector.m \
	GormScrollViewEditor.m \
	GormSetNameController.m \
	GormSound.m \
	GormSoundEditor.m \
	GormSoundInspector.m \
	GormSoundView.m \
	GormSplitViewEditor.m \
	GormStandaloneViewEditor.m \
	GormViewEditor.m \
	GormViewKnobs.m \
	GormViewSizeInspector.m \
	GormViewWindow.m \
	GormViewWithContentViewEditor.m \
	GormViewWithSubviewsEditor.m \
	GormWindowEditor.m \
	GormWindowTemplate.m \
	GormWrapperBuilder.m \
	GormWrapperLoader.m \
	NSCell+GormAdditions.m \
	NSColorWell+GormExtensions.m \
	NSFontManager+GormExtensions.m \
	NSView+GormExtensions.m \
        GormPrivate.m

-include GNUmakefile.preamble
-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble
