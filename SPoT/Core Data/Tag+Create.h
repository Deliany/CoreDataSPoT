//
//  Tag+Create.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
