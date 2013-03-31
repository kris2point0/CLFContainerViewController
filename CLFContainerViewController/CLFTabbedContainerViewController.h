//
//  CLFTabbedContainerViewController.h
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

#import "CLFContainerViewController.h"

/* This subclass of CLFContainerViewController is meant to give you a starting
 * point for creating tab-bar like view controller containers.
 *
 * A delegate has been provided that mimics the delegate for a
 * UITabBarController.
 *
 * There is no UI for switching view controllers included in this subclass.
 * It is up to you to determine and implement any UI that may be needed for
 * chosing different view controllers.
 */


@protocol CLFTabbedContainerViewControllerDelegate;


#pragma mark - Public Interface

@interface CLFTabbedContainerViewController : CLFContainerViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

@property (weak, nonatomic)
    id <CLFTabbedContainerViewControllerDelegate> delegate;

// Determines whether or not to animate the transition when calling
// switchToViewController: or switchToViewControllerAtIndex:
@property (nonatomic) BOOL animateTransitions;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties that should only be used by subclasses

// Your subclass can override these properties to provide a custom transition
// or it can override switchToViewController:animated:withCompletionBlock:
// and provide a custom transition from there.
@property (readonly, nonatomic) void (^preAnimationBlock)();
@property (readonly, nonatomic) NSArray *animationBlocks;
@property (readonly, nonatomic) NSArray *animationDurations;
@property (readonly, nonatomic) NSArray *animationOptions;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching View Controllers Simplified API

- (void)switchToViewController:(UIViewController *)viewController;

- (void)switchToViewControllerAtIndex:(NSUInteger)index;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate Helpers

// Give your subclass a chance to react to what the delegate returns for
// tabbedContainerViewController:shouldSelectViewController:
- (void)
delegateApprovedSwitchToViewController:(UIViewController *)viewController
                              animated:(BOOL)animated
                   withCompletionBlock:(void (^)(BOOL finished))completionBlock;

- (void)
delegateRefusedSwitchToViewController:(UIViewController *)viewController
                             animated:(BOOL)animated
                  withCompletionBlock:(void (^)(BOOL finished))completionBlock;

@end



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate Protocol

@protocol CLFTabbedContainerViewControllerDelegate <NSObject>
@optional

- (BOOL)tabbedContainerViewController:(CLFTabbedContainerViewController *)tabVC
           shouldSelectViewController:(UIViewController *)viewController;

- (void)tabbedContainerViewController:(CLFTabbedContainerViewController *)tabVC
              didSelectViewController:(UIViewController *)viewController; 

@end
