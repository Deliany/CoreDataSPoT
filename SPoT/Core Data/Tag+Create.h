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
+ (NSArray *)excludedTags;
+ (NSString *)AllTagName;
- (NSSet *)nonDeletedPhotos;
- (NSString *)capitalizedName;

@property (nonatomic, strong, readonly) NSString* sectionHeader;

@end
