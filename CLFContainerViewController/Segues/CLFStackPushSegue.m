//
//  CLFStackPushSegue.m
//  CLFLibrary
//
//  Created by Chris Flesner on 3/6/13.
//  Copyright (c) 2013 Chris Flesner. All rights reserved.
//

#import "CLFStackPushSegue.h"
#import "CLFStackContainerViewController.h"


@implementation CLFStackPushSegue

- (void)perform
{
    UIViewController *source = (UIViewController *)self.sourceViewController;
    UIViewController *destination =
        (UIViewController *)self.destinationViewController;

    CLFStackContainerViewController *stackContainer =
        (CLFStackContainerViewController *)source.parentViewController;

    NSAssert([stackContainer
              isKindOfClass:[CLFStackContainerViewController class]],
              @"CLFStackPushSegue is only meant to be used with a"
              @" CLFStackContainerViewController.");

    [stackContainer pushViewController:destination animated:YES];
}

@end
