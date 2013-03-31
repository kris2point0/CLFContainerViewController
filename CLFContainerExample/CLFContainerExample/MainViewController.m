//
//  MainViewController.m
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

#import "MainViewController.h"
#import "StackWithPopButtonViewController.h"
#import "StackChildViewController.h"
#import "WobbleContainerViewController.h"



@implementation MainViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    CLFStackContainerViewController *stackController =
        [self.storyboard
         instantiateViewControllerWithIdentifier:@"StackContainerVC"];
    CLFWobbleContainerViewController *wobbleController =
        [self.storyboard
         instantiateViewControllerWithIdentifier:@"WobbleContainerVC"];

    [self addViewController:stackController];
    [self addViewController:wobbleController];

    StackChildViewController *stackRoot =
        [self.storyboard
         instantiateViewControllerWithIdentifier:@"StackChildVC"];

    stackRoot.color = [UIColor darkGrayColor];
    stackRoot.title = @"Dark Gray";

    [stackController setupWithRootViewController:stackRoot];


    UIViewController *wobbleChild1 =
        [self.storyboard
         instantiateViewControllerWithIdentifier:@"WobbleChild1"];
    UIViewController *wobbleChild2 =
        [self.storyboard
         instantiateViewControllerWithIdentifier:@"WobbleChild2"];

    [wobbleController setupWithFistViewController:wobbleChild1
                          andSecondViewController:wobbleChild2];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.animateTransitions = ANIMATE_TRANSITIONS_BETWEEN_STACK_AND_WOBBLER;
}


- (void)
    delegateApprovedSwitchToViewController:(UIViewController *)viewController
{
    NSInteger newIndex = [self.viewControllers indexOfObject:viewController];
    self.vcSelectionControl.selectedSegmentIndex = newIndex;
}


- (void)delegateRefusedSwitchToViewController:(UIViewController *)viewController
                                     animated:(BOOL)animated
                          withCompletionBlock:(void (^)(BOOL))completionBlock
{
    NSInteger currentIndex =
        [self.viewControllers indexOfObject:self.currentViewController];
    self.vcSelectionControl.selectedSegmentIndex = currentIndex;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - User Interaction

- (IBAction)userTappedViewControllerSelection:(UISegmentedControl *)sender
{
    [self switchToViewControllerAtIndex:sender.selectedSegmentIndex];
}



@end
