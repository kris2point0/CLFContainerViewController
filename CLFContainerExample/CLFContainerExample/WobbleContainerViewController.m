//
//  WobbleContainerViewController.m
//  CLFContainerExample
//
//  Created by Chris Flesner on 3/27/13.
//  Copyright (c) 2013 Chris Flesner
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "WobbleContainerViewController.h"


@implementation WobbleContainerViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initial Setup

- (void)setupWithFistViewController:(UIViewController *)firstViewController
            andSecondViewController:(UIViewController *)secondViewController
{
    NSAssert(self.viewControllers.count == 0,
             @"Initial setup can only be performed once");

    [super addViewController:firstViewController];
    [super addViewController:secondViewController];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - VC Switching

- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
           withCompletionBlock:(void (^)(BOOL))completionBlock
{
    NSUInteger halfCycles = 16;

    __block CGFloat originYDelta = 35;
    CGFloat deltaOriginYDelta = originYDelta / halfCycles;

    __block NSInteger flipper = 1;

    __block CGFloat toAlpha = 0;
    __block CGFloat fromAlpha = 1;
    CGFloat deltaAlpha = 1.0 / halfCycles;

    NSTimeInterval duration = 0.2;
    NSTimeInterval deltaDuration = (duration / halfCycles) / 2;

    NSMutableArray *animations =
        [NSMutableArray arrayWithCapacity:halfCycles + 1];
    NSMutableArray *animationDurations =
        [NSMutableArray arrayWithCapacity:halfCycles + 1];
    NSMutableArray *animationOptions =
        [NSMutableArray arrayWithCapacity:halfCycles + 1];

    void (^preAnimationSetup)() = ^{
        self.transitionToViewController.view.alpha = toAlpha;
    };

    for (NSUInteger counter = 0; counter < halfCycles; counter++) {
        [animations addObject:^{
            toAlpha += deltaAlpha;
            fromAlpha -= deltaAlpha;

            CGRect mainFrame = self.view.bounds;

            self.transitionToViewController.view.frame =
                CGRectMake(mainFrame.origin.x,
                           mainFrame.origin.y - (originYDelta * flipper),
                           mainFrame.size.width, mainFrame.size.height);

            self.transitionFromViewController.view.frame =
                CGRectMake(mainFrame.origin.x,
                           mainFrame.origin.y + (originYDelta * flipper),
                           mainFrame.size.width, mainFrame.size.height);

            self.transitionToViewController.view.alpha = toAlpha;
            self.transitionFromViewController.view.alpha = fromAlpha;

            originYDelta -= deltaOriginYDelta;
            flipper = -flipper;
        }];

        [animationDurations addObject:@(duration)];
        [animationOptions addObject:@0];

        duration -= deltaDuration;
    }

    [animations addObject:^{
        self.transitionToViewController.view.frame = self.view.bounds;
        self.transitionFromViewController.view.frame = self.view.bounds;
        self.transitionToViewController.view.alpha = 1;
        self.transitionFromViewController.view.alpha = 0;
    }];
    
    [animationDurations addObject:@(duration)];
    [animationOptions addObject:@0];

    [self switchToViewController:toViewController
                        animated:animated
               preAnimationSetup:preAnimationSetup
                      animations:animations
              animationDurations:animationDurations
                animationOptions:animationOptions
                 completionBlock:completionBlock];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - User Interaction

- (IBAction)userRequestedOtherViewController:(UIButton *)sender
{
    NSParameterAssert(self.viewControllers.count == 2);
    
    NSInteger currentIndex =
        [self.viewControllers indexOfObject:self.currentViewController];
    
    [self switchToViewControllerAtIndex:!currentIndex animated:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Disabled Methods

- (void)addViewController:(UIViewController *)viewController
{
    NSAssert(NO, @"Use setupWithFirstViewController:andSecondViewController:");
}

- (void)removeViewController:(UIViewController *)viewController
{
    NSAssert(NO, @"You cannot remove a view controller from this container.");
}

@end
