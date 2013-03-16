//
//  ImageCacheManager.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 01.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "ImageCacheManager.h"

@implementation ImageCacheManager

+ (NSURL *)cacheImageDirectory
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheImageDir = [[urls lastObject] URLByAppendingPathComponent:@"image" isDirectory:YES];
    
    // creates image directory if it don't exists
    if (![cacheImageDir checkResourceIsReachableAndReturnError:nil]) {
        [fileManager createDirectoryAtURL:cacheImageDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return cacheImageDir;
}

+ (NSData*)getImageFromCacheWithName:(NSString*)imageName
{
    if (!imageName) {
        return nil;
    }
    
    NSURL *fileUrl = [[self cacheImageDirectory] URLByAppendingPathComponent:imageName];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:[fileUrl path]]) {
        return nil;
    }
    
    NSData *imageData = [NSData dataWithContentsOfURL:fileUrl];
    return imageData;
}

#define MAX_CACHE_DIR_SIZE 8000000

+ (void)writeImageToCacheWithData:(NSData*)imageData andFileName:(NSString*)fileName
{
    if (!fileName) {
        return;
    }
    
    NSURL *fileURL = [[self cacheImageDirectory] URLByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:[fileURL path]]) {
        return;
    }
    
    NSURL *cacheImageDir = [self cacheImageDirectory];
    unsigned long long cacheImageDirectorySize = [self directorySizeAtURL:cacheImageDir];
    
    while (cacheImageDirectorySize > MAX_CACHE_DIR_SIZE) {
        NSArray *filesURLs = [fileManager contentsOfDirectoryAtURL:cacheImageDir includingPropertiesForKeys:@[NSURLCreationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        
        NSURL *oldestFile;
        NSDate *oldestCreationDate = [NSDate date];
        
        NSDate *creationDate;
        for (NSURL* url in filesURLs) {
            [url getResourceValue:&creationDate forKey:NSURLCreationDateKey error:nil];
            
            if ([creationDate compare:oldestCreationDate] == NSOrderedAscending) {
                oldestCreationDate = creationDate;
                oldestFile = url;
            }
        }
        [fileManager removeItemAtURL:oldestFile error:nil];
        cacheImageDirectorySize = [self directorySizeAtURL:cacheImageDir];
    }
    
    [imageData writeToURL:fileURL atomically:YES];    
}

+ (unsigned long long)directorySizeAtURL:(NSURL*)url
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *filesURLs = [fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLFileSizeKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    unsigned long long directorySize = 0;
    NSNumber *fileSizeInBytes;
    for (NSURL* url in filesURLs) {
        [url getResourceValue:&fileSizeInBytes forKey:NSURLFileSizeKey error:nil];
        directorySize += [fileSizeInBytes unsignedLongLongValue];
    }
    
    return directorySize;
}

@end
