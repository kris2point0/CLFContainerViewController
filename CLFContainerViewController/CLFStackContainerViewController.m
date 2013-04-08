//
//  CLFStackContainerViewController.m
//  CLFLibrary
//
//  Created by Chris Flesner on 3/27/13.
//  Copyright (c) 2013 Chris Flesner
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of
//  the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//  THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "CLFStackContainerViewController.h"
#import "CLFStackPopSegue.h"


#pragma mark - Constants

#define _CLFStackDefaultTransitionDuration  0.5
#define _CLFStackDefaultTransitionOptions   0



#pragma mark - Implementation

@implementation CLFStackContainerViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup

- (void)setupWithRootViewController:(UIViewController *)rootViewController
{
    NSAssert(self.viewControllers.count == 0, @"You cannot set the root view controller more than once.");

    [super addViewController:rootViewController];
    [super switchToViewController:rootViewController
                         animated:NO
                preAnimationSetup:nil
                       animations:nil
               animationDurations:nil
                 animationOptions:nil
                  completionBlock:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters and Getters

- (UIViewController *)rootViewController
{
    return self.viewControllers[0];
}


- (UIViewController *)topViewController
{
    return [self.viewControllers lastObject];
}


- (void (^)())transitionUpPreAnimationBlock
{
    return ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame =
            CGRectMake(mainFrame.origin.x, mainFrame.origin.y + mainFrame.size.height,
                       mainFrame.size.width, mainFrame.size.height);
    };
}


- (NSArray *)transitionUpAnimationBlocks
{
    return @[ ^{
        CGRect mainFrame = self.childRestingFrame;
        
        self.transitionToViewController.view.frame = mainFrame;
        self.transitionFromViewController.view.frame =
            CGRectMake(mainFrame.origin.x, mainFrame.origin.y - mainFrame.size.height,
                       mainFrame.size.width, mainFrame.size.height);
    } ];
}


- (NSArray *)transitionUpAnimationDurations
{
    return @[ @(_CLFStackDefaultTransitionDuration) ];
}


- (NSArray *)transitionUpAnimationOptions
{
    return @[ @(_CLFStackDefaultTransitionOptions) ];
}


- (void (^)())transitionDownPreAnimationBlock
{
    return ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame =
            CGRectMake(mainFrame.origin.x, mainFrame.origin.y - mainFrame.size.height,
                       mainFrame.size.width, mainFrame.size.height);
    };
}


- (NSArray *)transitionDownAnimationBlocks
{
    return @[ ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame = mainFrame;
        self.transitionFromViewController.view.frame =
            CGRectMake(mainFrame.origin.x, mainFrame.origin.y + mainFrame.size.height,
                       mainFrame.size.width, mainFrame.size.height);
    } ];
}


- (NSArray *)transitionDownAnimationDurations
{
    return @[ @(_CLFStackDefaultTransitionDuration) ];
}


- (NSArray *)transitionDownAnimationOptions
{
    return @[ @(_CLFStackDefaultTransitionOptions) ];
}


- (void (^)())transitionLeftPreAnimationBlock
{
    return ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame =
            CGRectMake(mainFrame.origin.x + mainFrame.size.width, mainFrame.origin.y,
                       mainFrame.size.width, mainFrame.size.height);
    };
}


- (NSArray *)transitionLeftAnimationBlocks
{
    return @[ ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame = mainFrame;
        self.transitionFromViewController.view.frame =
            CGRectMake(mainFrame.origin.x - mainFrame.size.width, mainFrame.origin.y,
                       mainFrame.size.width, mainFrame.size.height);
    } ];
}


- (NSArray *)transitionLeftAnimationDurations
{
    return @[ @(_CLFStackDefaultTransitionDuration) ];
}


- (NSArray *)transitionLeftAnimationOptions
{
    return @[ @(_CLFStackDefaultTransitionOptions) ];
}


- (void (^)())transitionRightPreAnimationBlock
{
    return ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame =
            CGRectMake(mainFrame.origin.x - mainFrame.size.width, mainFrame.origin.y,
                       mainFrame.size.width, mainFrame.size.height);
    };
}


- (NSArray *)transitionRightAnimationBlocks
{
    return @[ ^{
        CGRect mainFrame = self.childRestingFrame;

        self.transitionToViewController.view.frame = mainFrame;
        self.transitionFromViewController.view.frame =
            CGRectMake(mainFrame.origin.x + mainFrame.size.width, mainFrame.origin.y,
                       mainFrame.size.width, mainFrame.size.height);
    } ];
}


- (NSArray *)transitionRightAnimationDurations
{
    return @[ @(_CLFStackDefaultTransitionDuration) ];
}


- (NSArray *)transitionRightAnimationOptions
{
    return @[ @(_CLFStackDefaultTransitionOptions) ];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push/Pop Simplified API

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    void (^preAnimationSetup)();
    NSArray *animationBlocks;
    NSArray *animationDurations;
    NSArray *animationOptions;
    
    switch (self.transitionDirections) {
        case CLFStackContainerPushUpPopDown:
            preAnimationSetup = self.transitionUpPreAnimationBlock;
            animationBlocks = self.transitionUpAnimationBlocks;
            animationDurations = self.transitionUpAnimationDurations;
            animationOptions = self.transitionUpAnimationOptions;
            break;
        case CLFStackContainerPushDownPopUp:
            preAnimationSetup = self.transitionDownPreAnimationBlock;
            animationBlocks = self.transitionDownAnimationBlocks;
            animationDurations = self.transitionDownAnimationDurations;
            animationOptions = self.transitionDownAnimationOptions;
            break;
        case CLFStackContainerPushLeftPopRight:
            preAnimationSetup = self.transitionLeftPreAnimationBlock;
            animationBlocks = self.transitionLeftAnimationBlocks;
            animationDurations = self.transitionLeftAnimationDurations;
            animationOptions = self.transitionLeftAnimationOptions;
            break;
        case CLFStackContainerPushRightPopLeft:
            preAnimationSetup = self.transitionRightPreAnimationBlock;
            animationBlocks = self.transitionRightAnimationBlocks;
            animationDurations = self.transitionRightAnimationDurations;
            animationOptions = self.transitionRightAnimationOptions;
            break;
    }

    [self pushViewController:viewController
                    animated:animated
           preAnimationSetup:preAnimationSetup
                  animations:animationBlocks
          animationDurations:animationDurations
            animationOptions:animationOptions
             completionBlock:nil];
}


- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    void (^preAnimationSetup)();
    NSArray *animationBlocks;
    NSArray *animationDurations;
    NSArray *animationOptions;

    switch (self.transitionDirections) {
        case CLFStackContainerPushUpPopDown:
            preAnimationSetup = self.transitionDownPreAnimationBlock;
            animationBlocks = self.transitionDownAnimationBlocks;
            animationDurations = self.transitionDownAnimationDurations;
            animationOptions = self.transitionDownAnimationOptions;
            break;
        case CLFStackContainerPushDownPopUp:
            preAnimationSetup = self.transitionUpPreAnimationBlock;
            animationBlocks = self.transitionUpAnimationOptions;
            animationDurations = self.transitionUpAnimationDurations;
            animationOptions = self.transitionUpAnimationOptions;
            break;
        case CLFStackContainerPushLeftPopRight:
            preAnimationSetup = self.transitionRightPreAnimationBlock;
            animationBlocks = self.transitionRightAnimationBlocks;
            animationDurations = self.transitionRightAnimationDurations;
            animationOptions = self.transitionRightAnimationOptions;
            break;
        case CLFStackContainerPushRightPopLeft:
            preAnimationSetup = self.transitionLeftPreAnimationBlock;
            animationBlocks = self.transitionLeftAnimationBlocks;
            animationDurations = self.transitionLeftAnimationDurations;
            animationOptions = self.transitionLeftAnimationOptions;
            break;
    }

    return [self popToViewController:viewController
                            animated:animated
                   preAnimationSetup:preAnimationSetup
                          animations:animationBlocks
                  animationDurations:animationDurations
                    animationOptions:animationOptions
                     completionBlock:nil];
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    NSParameterAssert(self.viewControllers.count > 1);

    UIViewController *controllerToPopTo = self.viewControllers[self.viewControllers.count - 2];
    
    return [self popToViewController:controllerToPopTo animated:animated][0];
}


- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:self.rootViewController animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push/Pop

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
         preAnimationSetup:(void (^)())preAnimationSetup
                animations:(NSArray *)animationBlocks
        animationDurations:(NSArray *)animationDurations
          animationOptions:(NSArray *)animationOptions
           completionBlock:(void (^)(BOOL))completionBlock
{
    NSAssert(self.rootViewController,
             @"You must have a root view controller set before pushing another view controller.");

    [super addViewController:viewController];
    [super switchToViewController:viewController
                         animated:animated
                preAnimationSetup:preAnimationSetup
                       animations:animationBlocks
               animationDurations:animationDurations
                 animationOptions:animationOptions
                  completionBlock:completionBlock];
}


- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated
               preAnimationSetup:(void (^)())preAnimationSetup
                      animations:(NSArray *)animationBlocks
              animationDurations:(NSArray *)animationDurations
                animationOptions:(NSArray *)animationOptions
                 completionBlock:(void (^)(BOOL))completionBlock
{
    NSAssert([self.viewControllers containsObject:viewController],
             @"You cannot pop to a view controller that is not in the viewControllers array.");

    if (viewController == self.topViewController)
        return nil;

    NSUInteger indexOfVC = [self.viewControllers indexOfObject:viewController];
    NSRange popRange = NSMakeRange(indexOfVC + 1, self.viewControllers.count - indexOfVC - 1);
    
    NSArray *poppedVCs = [self.viewControllers subarrayWithRange:popRange];

    [super switchToViewController:viewController
                         animated:animated
                preAnimationSetup:preAnimationSetup
                       animations:animationBlocks
               animationDurations:animationDurations
                 animationOptions:animationOptions
                  completionBlock:^(BOOL finished) {
        for (UIViewController *vc in poppedVCs)
            [super removeViewController:vc];

        if (completionBlock) completionBlock(finished);
    }];

    return poppedVCs;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Unwind Segues

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    UIViewController *vcForSegue;

    for (UIViewController *vc in self.viewControllers) {
        if ([vc respondsToSelector:action]) {
            vcForSegue = vc;
            break;
        }
    }

    if (!vcForSegue) {
        vcForSegue = [super viewControllerForUnwindSegueAction:action
                                            fromViewController:fromViewController
                                                    withSender:sender];
    }

    return vcForSegue;
}


- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController
                                      fromViewController:(UIViewController *)fromViewController
                                              identifier:(NSString *)identifier
{
    return [[CLFStackPopSegue alloc] initWithIdentifier:identifier
                                                 source:fromViewController
                                            destination:toViewController];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Disabled Methods

- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
             preAnimationSetup:(void (^)())preAnimationSetup
                    animations:(NSArray *)animationBlocks
            animationDurations:(NSArray *)animationDurations
              animationOptions:(NSArray *)animationOptions
               completionBlock:(void (^)(BOOL))completionBlock
{
    NSAssert(NO, @"You should use the push and pop methods provided by CLFStackContainerViewController.");
}


- (void)addViewController:(UIViewController *)viewController
{
    NSAssert(NO, @"CLFStackContainerViewController will add view controllers for you when you push them.");
}


- (void)removeViewController:(UIViewController *)viewController
{
    NSAssert(NO, @"CLFStackContainerViewController will remove view controllers for you when you pop them.");
}

@end
