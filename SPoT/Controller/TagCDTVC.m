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
#import "Photo+Flickr.h"
#import "CoreDataHelper.h"

@interface TagCDTVC ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation TagCDTVC

#pragma mark - Properties

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionHeader" cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"All"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Tag"];
    }
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[tag.name capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    
    NSSet *photos = [tag nonDeletedPhotos];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", [photos count], [photos count] > 1 ? @"s" : @""];
    
    return cell;
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.managedObjectContext) {
        [self useSharedDocument];
    }
    // perform the fetch again (in case we deleted any photos)
    [self performFetch];
}

- (void)useSharedDocument
{
    CoreDataHelper *dataHelper = [CoreDataHelper sharedManagedDocument];
    UIManagedDocument *document = dataHelper.sharedDocument;
    NSURL *url = document.fileURL;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        // create it
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self refresh];
            }
        }];
    } else if (document.documentState == UIDocumentStateClosed) {
        // open it
        [document openWithCompletionHandler:^(BOOL success){
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        // try to use it
        self.managedObjectContext = document.managedObjectContext;
    }
}

#pragma mark - Segue

#define FEATURED_SEGUE_ID @"Show Featured"
#define ALL_SEGUE_ID @"Show All"

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
        } else if ([segue.identifier isEqualToString:ALL_SEGUE_ID]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setManagedObjectContext:)]) {
                [segue.destinationViewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
            }
        }
    }
}

#pragma mark - Refresh

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loaderQ = dispatch_queue_create("flickr photo loader", NULL);
    dispatch_async(loaderQ, ^{
        NSArray *stanfordPhotos = [FlickrFetcher stanfordPhotos];
        // put the photos in Core Data database
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in stanfordPhotos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

@end
