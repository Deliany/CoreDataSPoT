//
//  CoreDataHelper.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 17.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject

@property (strong, nonatomic, readonly) UIManagedDocument *sharedDocument;

+ (CoreDataHelper *)sharedManagedDocument;

@end
