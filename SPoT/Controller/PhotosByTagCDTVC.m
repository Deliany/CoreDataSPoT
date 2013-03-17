//
//  PhotosByTagCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "PhotosByTagCDTVC.h"
#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag.h"

@implementation PhotosByTagCDTVC

#pragma mark - Properties

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = [[tag.name capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [self photoListPredicate];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.tag.managedObjectContext sectionNameKeyPath:@"sectionHeader" cacheName:nil];
    }
}

- (NSPredicate*)photoListPredicate{
    return [NSPredicate predicateWithFormat:@"%@ IN tags AND displayed=YES",self.tag];
}


-(NSPredicate*)searchPredicateWithSeachString:(NSString*)searchString{
    if ([searchString length] > 0) {
        return [NSPredicate predicateWithFormat:@"%@ IN tags AND displayed=YES AND (title contains[cd] %@)", self.tag, searchString];
    }
    else {
        return [self photoListPredicate];
    }
}



@end
