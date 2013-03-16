//
//  NetworkActivityIndicatorManager.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 01.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "NetworkActivityIndicatorManager.h"


@implementation NetworkActivityIndicatorManager

static NSInteger countOfConcurrentRequests;

+ (void)addToConcurrentRequests:(NSInteger)amount
{
    if ((countOfConcurrentRequests + amount) < 0) {
        return;
    }
    countOfConcurrentRequests += amount;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = countOfConcurrentRequests > 0 ? YES : NO;
}

+ (void) networkActivityIndicatorShouldShow
{
    [self addToConcurrentRequests:1];
}
+ (void) networkActivityIndicatorShouldHide
{
    [self addToConcurrentRequests:-1];
}

@end
