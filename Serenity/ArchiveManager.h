//
//  ArchiveController.h
//  DeluxeHome
//
//  Created by Thinaire on 7/9/13.
//  Copyright (c) 2014 Thinaire. All rights reserved.

/* This object takes NSData objects and writes it out in a keyed archive
 */

#import <Foundation/Foundation.h>

@interface ArchiveManager : NSObject

    - (NSString *)dataPathWithFile:(NSString*)fileName;

    - (void) addObjectToArchive:(id)objectToSave;
    - (void) addObjectToArchive:(id)objectToSave withKey:(NSString*)keyName;
    - (NSData*) archive;

    - (BOOL) saveArchiveToFile:(NSString*)fileName ;

    - (BOOL) openPathWithFile:(NSString*)fileName ;

    - (id) objectFromArchiveWithKey:(NSString*)keyName;
    - (NSArray*) archiveDirectory; // list all of the objects written to the archive

    - (void) close;
@end
