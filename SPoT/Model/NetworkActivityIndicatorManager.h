//
//  NetworkActivityIndicatorManager.h
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 01.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Simple manager for network activity indicator
 * You just requests to show or hide the indicator
 **/
@interface NetworkActivityIndicatorManager : NSObject

/**
 * Request to show network indicator
 **/
+ (void) networkActivityIndicatorShouldShow;

/**
 * Request to hide network indicator
 * Will not hide indicator if it is accessing from multiple points
 * Only deny one show request per call
 **/
+ (void) networkActivityIndicatorShouldHide;

@end
