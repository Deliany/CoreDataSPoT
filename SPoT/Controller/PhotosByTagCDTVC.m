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

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Properties

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = tag.name;
    self.managedObjectContext = tag.managedObjectContext;
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"%@ in tags", self.tag];
        
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
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr PhotosForTag Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photosForTag = [FlickrFetcher photosForTag:self.tag.name];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photosForTag) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

@end
