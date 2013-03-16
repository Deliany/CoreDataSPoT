//
//  FlickrPhotoCDTVC.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface FlickrPhotoCDTVC : CoreDataTableViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)refresh; // abstract

@end
