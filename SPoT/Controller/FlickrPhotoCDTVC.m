//
//  FlickrPhotoCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "FlickrPhotoCDTVC.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@implementation FlickrPhotoCDTVC

#pragma mark - View Controller Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self useDemoDocument];
    [self refresh];
}

- (void)useDemoDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"CoreDataModel"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self fetchAllPhotosToDB];
                  [self refresh];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}

#pragma mark - Refreshing

- (IBAction)refresh
{
    // abstract
}

- (void) fetchAllPhotosToDB
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr All Photos Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photosForTag = [FlickrFetcher stanfordPhotos];
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

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    // add the bar button from its toolbar
    barButtonItem.title = @"Images";
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)sender
     willShowViewController:(UIViewController *)master
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove the bar button from its toolbar
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
}

#pragma mark - Segue

// typical “setSplitViewBarButton:” method

- (id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)])
    {
        detail = nil;
    }
    return detail;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}


@end
