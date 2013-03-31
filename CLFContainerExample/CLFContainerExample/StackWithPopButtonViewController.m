//
//  StackWithPopButtonViewController.m
//  CLFContainerExample
//
//  Created by Chris Flesner on 3/28/13.
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

#import "StackWithPopButtonViewController.h"


#pragma mark - Private Interface

@interface StackWithPopButtonViewController ()

@property (weak, nonatomic) IBOutlet UIButton *popButton;

@end



#pragma mark - Implementation

@implementation StackWithPopButtonViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.transitioning)
        [self setPopButtonTitleForViewController:self.currentViewController];

    if (self.viewControllers.count <= 1)
        self.popButton.alpha = 0;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push/Pop

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    void (^preAnimationSetup)() = ^{
        self.transitionUpPreAnimationBlock();
        [self
         setPopButtonTitleForViewController:self.transitionToViewController];
    };
    
    NSArray *animations = @[ ^{
        void (^transitionUpBlock)() = self.transitionUpAnimationBlocks[0];
        transitionUpBlock();

        self.popButton.alpha = 1;
    } ];
    
    NSArray *animationDurations = @[ @0.5 ];
    NSArray *animationOptions = @[ @0 ];

    [self pushViewController:viewController
                    animated:animated
           preAnimationSetup:preAnimationSetup
                  animations:animations
          animationDurations:animationDurations
            animationOptions:animationOptions
             completionBlock:nil];
}


- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated
{
    void (^preAnimationSetup)() = ^{
        self.transitionDownPreAnimationBlock();
        [self
         setPopButtonTitleForViewController:self.transitionToViewController];
    };

    NSArray *animations = @[ ^{
        void (^transitionDownBlock)() = self.transitionDownAnimationBlocks[0];
        transitionDownBlock();

        self.popButton.alpha =
            self.transitionToViewController == self.rootViewController ? 0 : 1;
    } ];
    
    NSArray *durations = @[ @0.5 ];
    NSArray *options = @[ @0 ];

    return [self popToViewController:viewController
                            animated:animated
                   preAnimationSetup:preAnimationSetup
                          animations:animations
                  animationDurations:durations
                    animationOptions:options
                     completionBlock:nil];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Back Button

- (IBAction)userTappedPopButton:(UIButton *)sender
{
    if (!self.transitioning)
        [self popViewControllerAnimated:YES];
}


- (void)setPopButtonTitleForViewController:(UIViewController *)viewController
{
    NSUInteger vcIndex = [self.viewControllers indexOfObject:viewController];

    if (vcIndex == 0 || vcIndex == NSNotFound)
        return;

    UIViewController *backVC = self.viewControllers[vcIndex - 1];
    NSString *title = [NSString stringWithFormat:@"Pop to %@", backVC.title];

    [self.popButton setTitle:title
                     forState:UIControlStateNormal];
    [self.popButton setTitle:title
                     forState:UIControlStateSelected];
}


@end
