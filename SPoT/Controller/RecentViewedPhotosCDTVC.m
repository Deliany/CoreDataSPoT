//
//  RecentViewedPhotosCDTVC.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "RecentViewedPhotosCDTVC.h"
#import "CoreDataHelper.h"


@interface RecentViewedPhotosCDTVC()

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation RecentViewedPhotosCDTVC

#define MAX_RECENT_PHOTOS_TO_SHOW 5

- (void)reloadRecentList
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewDate" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewDate != nil AND displayed=YES"];
        request.fetchLimit = MAX_RECENT_PHOTOS_TO_SHOW;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self reloadRecentList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext)
        self.managedObjectContext = [CoreDataHelper sharedManagedDocument].sharedDocument.managedObjectContext;
}

@end
