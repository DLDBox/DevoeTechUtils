//
//  ArchiveController.m
//  DeluxeHome
//
//  Created by Thinaire.
//  Copyright (c) 2014 Thinaire. All rights reserved.

#import "ArchiveManager.h"

@interface ArchiveManager()
    @property(nonatomic,strong) NSKeyedArchiver* archiver;
    @property(nonatomic,strong) NSKeyedUnarchiver* unarchiver;
    @property(nonatomic,strong) NSMutableData* mutableData;
    @property(nonatomic,strong) NSData* readData;

    @property(nonatomic,strong) NSMutableArray* archiveDirectory;
@end

static NSString* const KEY_ARCHIVE_DIRECTORY = @"com.devoetech.archivedirectory";

@implementation ArchiveManager

- (NSString *)dataPathWithFile:(NSString*)fileName
{
    static NSString* strPath ;
    
    if( strPath == nil )
    {
        strPath = [[NSString alloc] initWithFormat:@"%@/Documents/%@", NSHomeDirectory(),fileName] ;
    }
    return strPath ;
}

- (id) init
{
    self = [super init];
    if( self)
    {
        _archiveDirectory = [NSMutableArray new];
    }
    return self ;
}

- (void) addObjectToArchive:(id)objectToSave
{
    if ( !_archiver ) {
        _mutableData = [[NSMutableData data] init];
        _archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:_mutableData];
    }
    [self.archiver encodeObject:objectToSave];
}

- (void) addObjectToArchive:(id)objectToSave withKey:(NSString*)keyName
{
    if ( !_archiver ) {
        _mutableData = [[NSMutableData data] init];
        _archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:_mutableData];
    }
    if ( keyName ) {
        [self.archiver encodeObject:objectToSave forKey:keyName];
        [_archiveDirectory addObject:keyName];
    }
    else {
        [self.archiver encodeObject:objectToSave];
    }
}

- (BOOL) saveArchiveToFile:(NSString*)fileName
{
    NSString* filePath = [self dataPathWithFile:fileName];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath ] )
    {
        NSError* err ;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err ] ;
    }
    
    [self.archiver encodeObject:_archiveDirectory forKey:KEY_ARCHIVE_DIRECTORY];
    
    [self.archiver finishEncoding];
    
    if( ![self.mutableData writeToFile:filePath atomically:YES] )
    {
        DLog( @"Error archiving data" ) ;
        return FALSE ;
    }
    
    return TRUE ;
}

- (NSData*) archive
{
    [self.archiver finishEncoding];
    return self.mutableData;
}

/////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL) openPathWithFile:(NSString*)fileName
{
    NSString* dataPath = [self dataPathWithFile:fileName];
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:dataPath] ) {
        return FALSE;
    }

    self.readData = [[NSData alloc] initWithContentsOfFile:dataPath];
    self.unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.readData];
    
    return TRUE;
}

- (id) objectFromArchiveWithKey:(NSString*)keyName
{
    return [self.unarchiver decodeObjectForKey:keyName];
}

- (NSArray*)archiveDirectory
{
    if ( [self.archiveDirectory count] == 0) {
        self.archiveDirectory = [self objectFromArchiveWithKey:KEY_ARCHIVE_DIRECTORY];
    }
    return self.archiveDirectory;
}

- (void) close
{
    [self.unarchiver finishDecoding];
}

//- (void) closeArchiver
//{
//    [self.archiver finishEncoding];
//}

@end
