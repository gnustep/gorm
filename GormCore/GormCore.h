/* GormCore.h
*
* Copyright (C) 2019 Free Software Foundation, Inc.
*
* Author:  Lars Sonchocky-Helldorf
* Date:  01.11.19
*
* This file is part of GNUstep.
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation; either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/

#import <Foundation/Foundation.h>

#ifndef GNUSTEP
//! Project version number for GormCore.
FOUNDATION_EXPORT double GormCoreVersionNumber;

//! Project version string for GormCore.
FOUNDATION_EXPORT const unsigned char GormCoreVersionString[];
#endif

#ifndef INCLUDED_GORMCORE_H
#define INCLUDED_GORMCORE_H
 
#include <GormCore/GormBoxEditor.h>
#include <GormCore/GormClassEditor.h>
#include <GormCore/GormClassInspector.h>
#include <GormCore/GormClassManager.h>
#include <GormCore/GormClassPanelController.h>
#include <GormCore/GormConnectionInspector.h>
#include <GormCore/GormControlEditor.h>
#include <GormCore/GormCustomClassInspector.h>
#include <GormCore/GormCustomView.h>
#include <GormCore/GormDefines.h>
#include <GormCore/GormDocument.h>
#include <GormCore/GormDocumentController.h>
#include <GormCore/GormDocumentWindow.h>
#include <GormCore/GormFilePrefsManager.h>
#include <GormCore/GormFilesOwner.h>
#include <GormCore/GormFontViewController.h>
#include <GormCore/GormFunctions.h>
#include <GormCore/GormGenericEditor.h>
#include <GormCore/GormHelpInspector.h>
#include <GormCore/GormImage.h>
#include <GormCore/GormImageEditor.h>
#include <GormCore/GormImageInspector.h>
#include <GormCore/GormInspectorsManager.h>
#include <GormCore/GormInternalViewEditor.h>
#include <GormCore/GormMatrixEditor.h>
#include <GormCore/GormNSPanel.h>
#include <GormCore/GormNSSplitViewInspector.h>
#include <GormCore/GormNSWindow.h>
#include <GormCore/GormNSWindowView.h>
#include <GormCore/GormObjectEditor.h>
#include <GormCore/GormObjectInspector.h>
#include <GormCore/GormOpenGLView.h>
#include <GormCore/GormOutlineView.h>
#include <GormCore/GormPalettesManager.h>
#include <GormCore/GormPlacementInfo.h>
#include <GormCore/GormPlugin.h>
#include <GormCore/GormPluginManager.h>
#include <GormCore/GormPrivate.h>
#include <GormCore/GormProtocol.h>
#include <GormCore/GormResource.h>
#include <GormCore/GormResourceEditor.h>
#include <GormCore/GormResourceManager.h>
#include <GormCore/GormScrollViewAttributesInspector.h>
#include <GormCore/GormServer.h>
#include <GormCore/GormSetNameController.h>
#include <GormCore/GormSound.h>
#include <GormCore/GormSoundEditor.h>
#include <GormCore/GormSoundInspector.h>
#include <GormCore/GormSoundView.h>
#include <GormCore/GormSplitViewEditor.h>
#include <GormCore/GormStandaloneViewEditor.h>
#include <GormCore/GormViewEditor.h>
#include <GormCore/GormViewKnobs.h>
#include <GormCore/GormViewSizeInspector.h>
#include <GormCore/GormViewWindow.h>
#include <GormCore/GormViewWithContentViewEditor.h>
#include <GormCore/GormViewWithSubviewsEditor.h>
#include <GormCore/GormWindowEditor.h>
#include <GormCore/GormWindowTemplate.h>
#include <GormCore/GormWrapperBuilder.h>
#include <GormCore/GormWrapperLoader.h>
#include <GormCore/NSCell+GormAdditions.h>
#include <GormCore/NSColorWell+GormExtensions.h>
#include <GormCore/NSFontManager+GormExtensions.h>
#include <GormCore/NSView+GormExtensions.h>

#endif

