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

@end
