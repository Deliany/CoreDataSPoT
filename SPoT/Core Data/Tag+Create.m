//
//  Tag+Create.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    
    if (name.length) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tag.name = name;
        } else {
            tag = [matches lastObject];
        }
    }
    
    return tag;
}

// triming to show '$All' tag as 'All'
-(NSString *)sectionHeader
{
    return [[[self.name substringToIndex:1] capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
}

- (NSString *)capitalizedName
{
    return [self.name capitalizedString];
}

- (NSSet *)nonDeletedPhotos
{
    return [self.photos filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"displayed=YES"]];
}

+ (NSString *)AllTagName
{
    return @"$All"; // # sorts before any letter 'a'..'z','A'..'Z'
}

+ (NSArray*)excludedTags
{
    static NSArray* excludedTags = nil;
    if (!excludedTags) {
        excludedTags = @[@"cs193pspot",@"portrait",@"landscape"];
    }
    return excludedTags;
}

@end
