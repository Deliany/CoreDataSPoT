//
//  Photo.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 17.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * displayed;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * largeImageUrl;
@property (nonatomic, retain) NSDate * lastViewDate;
@property (nonatomic, retain) NSString * originalImageUrl;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSString * thumbnailImageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
