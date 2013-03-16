//
//  Photo.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * shortInfo;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * urlLarge;
@property (nonatomic, retain) NSString * urlOriginal;
@property (nonatomic, retain) NSString * urlThumbnail;
@property (nonatomic, retain) NSData * imageThumbnail;
@property (nonatomic, retain) NSDate * lastViewDate;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Photographer *owner;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
