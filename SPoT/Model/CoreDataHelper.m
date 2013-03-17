//
//  CoreDataHelper.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 17.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "CoreDataHelper.h"

@interface CoreDataHelper()

@property (readwrite, strong, nonatomic) UIManagedDocument *sharedDocument;

@end

@implementation CoreDataHelper

+ (CoreDataHelper *)sharedManagedDocument
{
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[CoreDataHelper alloc] init];
    });
    return _sharedInstance;
}

- (UIManagedDocument *)sharedDocument
{
    if (!_sharedDocument) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"flickrPhotosDB"];
        _sharedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _sharedDocument;
}

@end
