//
//  ImageCacheManager.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 01.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Manager for caching images from and to FS(File System).
 * Can fetch image data from cache folder in FS if it is present there.
 * Can write image data to cache folder in FS. Note that there is cache folder size limit.
 **/
@interface ImageCacheManager : NSObject

/**
 * Fetches image data from file if it exists
 * @return Data of image file or nil if file don't exists
 **/
+ (NSData*)getImageFromCacheWithName:(NSString*)imageName;

/**
 * Creates file with given name in cache folder and stores image data there
 * If cache folder exceeds predefined size, oldest files will be automatically deleted
 **/
+ (void)writeImageToCacheWithData:(NSData*)imageData andFileName:(NSString*)fileName;

@end
