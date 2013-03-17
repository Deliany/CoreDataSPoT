//
//  FlickrPhotoCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "FlickrPhotoCDTVC.h"
#import "ImageViewController.h"
#import "Photo.h"
#import "NetworkActivityIndicatorManager.h"

@interface FlickrPhotoCDTVC () <UISplitViewControllerDelegate>

@end


@implementation FlickrPhotoCDTVC

- (Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    cell.imageView.image = nil; // because we reuse cells we have to clear the image
    Photo *photo = [self photoForRowAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    if (!photo.thumbnailImage) {
        // if the thumbnail is not in the database then get it from Flickr
        dispatch_queue_t thumbnailQ = dispatch_queue_create("thumbnail loader", NULL);
        dispatch_async(thumbnailQ, ^{
            // if the tumbnail is not in the database then get it from Flickr
            NSData *thumbnailData = photo.thumbnailImage;
            if (!thumbnailData) {
                [NetworkActivityIndicatorManager networkActivityIndicatorShouldShow];
                NSURL *url = [NSURL URLWithString:photo.thumbnailImageUrl];
                thumbnailData = [[NSData alloc] initWithContentsOfURL:url];
                [NetworkActivityIndicatorManager networkActivityIndicatorShouldHide];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // put the image in the cell imageView and mark the cell for redraw
                cell.imageView.image = [UIImage imageWithData:thumbnailData];
                [cell setNeedsLayout];
                // store the thumbnail in the database
                [photo.managedObjectContext performBlock:^{
                    photo.thumbnailImage = thumbnailData;
                }];
            });
        });
    } else
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailImage];
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
                    
                    [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
                    Photo *photo = [self photoForRowAtIndexPath:indexPath];
                    
                    photo.lastViewDate = [NSDate date];
                    
                    NSURL *url = [NSURL URLWithString:photo.largeImageUrl];
                    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
                        [self performSelector:@selector(transferSplitViewBarButtonItemToViewController:) withObject:segue.destinationViewController];
                        url = [NSURL URLWithString:photo.originalImageUrl];
                    }
           
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:photo.title];
                }
            }
        }
    }
}

- (void)removePhotoFromDisplayedPhotosForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self photoForRowAtIndexPath:indexPath];
    photo.displayed = @(NO);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self removePhotoFromDisplayedPhotosForRowAtIndexPath:indexPath];
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }
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
