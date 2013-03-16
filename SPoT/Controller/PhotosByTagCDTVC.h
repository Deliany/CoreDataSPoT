//
//  PhotosByTagCDTVC.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "FlickrPhotoCDTVC.h"

@class Tag;

@interface PhotosByTagCDTVC : FlickrPhotoCDTVC

@property (nonatomic, strong) Tag *tag;

@end
