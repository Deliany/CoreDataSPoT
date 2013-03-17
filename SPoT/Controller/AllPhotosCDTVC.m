//
//  AllPhotosCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 17.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "AllPhotosCDTVC.h"
#import "Photo.h"
#import "Tag+Create.h"

@implementation AllPhotosCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    self.title = @"Photos by tag";
    if (managedObjectContext) {
        NSFetchRequest *requestTags = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        requestTags.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        requestTags.predicate = [NSPredicate predicateWithFormat:@"name!=%@",[Tag AllTagName]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:requestTags managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"capitalizedName" cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSSet *photosInSection = ((Tag *)[[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section]).photos;
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"displayed=YES"];
    NSSet *visiblePhotosInSection = [photosInSection filteredSetUsingPredicate:filterPredicate];
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *sortedVisiblePhotosInSection = [visiblePhotosInSection sortedArrayUsingDescriptors:sortDescriptors];
    return sortedVisiblePhotosInSection[indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self.fetchedResultsController fetchedObjects] objectAtIndex:section] nonDeletedPhotos] count];
}

@end
