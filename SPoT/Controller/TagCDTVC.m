//
//  TagCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "TagCDTVC.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"

@implementation TagCDTVC

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Properties

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        [self refresh];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [tag.name capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", [tag.photos count], [tag.photos count] > 1 ? @"s" : @""];
    
    return cell;
}

#pragma mark - Segue

#define FEATURED_SEGUE_ID @"Show Featured"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:FEATURED_SEGUE_ID]) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
            }
        }
    }
}

#pragma mark - Refreshing

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Tags Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *tags = [[FlickrFetcher filteredTags] allObjects];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
            for (NSString *name in tags) {
                [Tag tagWithName:name inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

@end
