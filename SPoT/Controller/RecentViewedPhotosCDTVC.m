//
//  RecentViewedPhotosCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "RecentViewedPhotosCDTVC.h"
#import "Photo.h"
#import "Tag+Create.h"
#import "FlickrFetcher.h"


@implementation RecentViewedPhotosCDTVC

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Properties

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewDate" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewDate != nil"];
        [request setFetchLimit:10];
        
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
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.shortInfo;
    cell.imageView.image = [UIImage imageWithData:photo.imageThumbnail];
    
    return cell;
    
}

#pragma mark - Segue

#define SHOW_IMAGE_SEGUE_ID @"Show Image"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:SHOW_IMAGE_SEGUE_ID]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    
                    photo.lastViewDate = [NSDate date];
                    
                    
                    NSURL *url = [NSURL URLWithString:photo.urlLarge];
                    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
                        [self performSelector:@selector(transferSplitViewBarButtonItemToViewController:) withObject:segue.destinationViewController];
                        url = [NSURL URLWithString:photo.urlOriginal];
                    }
                    
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:photo.title];
                    
                }
            }
        }
    }
}

#pragma mark - Refreshing

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    [self performFetch];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];

}

@end
