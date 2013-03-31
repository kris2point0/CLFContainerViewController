//
//  CLFTabbedContainerViewController.m
//  CLFLibrary
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

#import "CLFTabbedContainerViewController.h"



@implementation CLFTabbedContainerViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Controller Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.preAnimateWhenInterruptingWithToTranistionToFromViewController = NO;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters and Getters

- (BOOL)animateWhenInsertingOrRemovingViewControllerAtCurrentIndex
{
    return self.animateTransitions;
}


- (void (^)())preAnimationBlock
{
    return ^{
        self.transitionToViewController.view.alpha = 0;
    };
}


- (NSArray *)animationBlocks
{
    return @[ ^{
        self.transitionToViewController.view.alpha = 1;
        self.transitionFromViewController.view.alpha = 0;
    } ];
}


- (NSArray *)animationDurations
{
    return @[ @0.5 ];
}


- (NSArray *)animationOptions
{
    return @[ @(UIViewAnimationOptionBeginFromCurrentState) ];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - VC Switching Simplified API

- (void)switchToViewControllerAtIndex:(NSUInteger)index
{
    [self switchToViewControllerAtIndex:index animated:self.animateTransitions];
}


- (void)switchToViewController:(UIViewController *)viewController
{
    [self switchToViewController:viewController
                        animated:self.animateTransitions];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - VC Switching

- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
           withCompletionBlock:(void (^)(BOOL))completionBlock
{
    SEL shouldSwitchSel =
        @selector(tabbedContainerViewController:shouldSelectViewController:);
    SEL didSwitchSel =
        @selector(tabbedContainerViewController:didSelectViewController:);

    if ([self.delegate respondsToSelector:shouldSwitchSel]) {
        if (![self.delegate tabbedContainerViewController:self
                               shouldSelectViewController:toViewController])
        {
            [self delegateRefusedSwitchToViewController:toViewController
                                               animated:animated
                                    withCompletionBlock:completionBlock];
            return;
        }
    }

    [self delegateApprovedSwitchToViewController:toViewController
                                        animated:animated
                             withCompletionBlock:completionBlock];

    void (^preAnimationSetup)() = self.preAnimationBlock;
    NSArray *animationBlocks = self.animationBlocks;
    NSArray *animationDurations = self.animationDurations;
    NSArray *animationOptions = self.animationOptions;

    [super switchToViewController:toViewController
                         animated:animated
                preAnimationSetup:preAnimationSetup
                       animations:animationBlocks
               animationDurations:animationDurations
                 animationOptions:animationOptions
                  completionBlock:^(BOOL finished) {
        if (completionBlock) completionBlock(finished);

        if ([self.delegate respondsToSelector:didSwitchSel]) {
            [self.delegate tabbedContainerViewController:self
                                 didSelectViewController:toViewController];
        }
    }];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate Helpers

- (void)
delegateApprovedSwitchToViewController:(UIViewController *)viewController
                              animated:(BOOL)animated
                   withCompletionBlock:(void (^)(BOOL))completionBlock
{
    // Reserved for subclassing
}


- (void)delegateRefusedSwitchToViewController:(UIViewController *)viewController
                                     animated:(BOOL)animated
                          withCompletionBlock:(void (^)(BOOL))completionBlock
{
    // Reserved for subclassing
}

@end
