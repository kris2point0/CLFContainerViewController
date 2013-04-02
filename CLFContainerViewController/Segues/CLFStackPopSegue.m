//
//  CLFStackPopSegue.m
//  CLFLibrary
//
//  Created by Chris Flesner on 3/23/13.
//  Copyright (c) 2013 Chris Flesner. All rights reserved.
//

#import "CLFStackPopSegue.h"
#import "CLFStackContainerViewController.h"


@implementation CLFStackPopSegue

- (void)perform
{
    UIViewController *source = (UIViewController *)self.sourceViewController;
    UIViewController *destination =
        (UIViewController *)self.destinationViewController;

    CLFStackContainerViewController *stackContainer =
        (CLFStackContainerViewController *)source.parentViewController;

    NSAssert([stackContainer
              isKindOfClass:[CLFStackContainerViewController class]],
              @"CLFStackPopSegue is only meant to be used with a"
              @" CLFStackContainerViewController.");

    [stackContainer popToViewController:destination animated:YES];
}

@end
