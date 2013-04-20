//
//  CLFContainerViewController.m
//  CLFLibrary
//
//  Created by Chris Flesner on 3/23/13.
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

#import "CLFContainerViewController.h"


#pragma mark - Private Interface

@interface CLFContainerViewController ()
{
    NSMutableArray *_viewControllers;
}

@property (strong, nonatomic) UIViewController *currentViewController;

@property (nonatomic) BOOL transitioning;
@property (strong, nonatomic) UIViewController *transitionFromViewController;
@property (strong, nonatomic) UIViewController *transitionToViewController;

// Whether or not this is the first time viewWillAppear and viewDidAppear is being called.
@property (nonatomic) BOOL appearedBefore;

// If the container gets sent viewDidDisappear in the middle of a transition this property is used to let us know that
// we need to disppear the child view controller as soon as the transition is wrapped up.
@property (nonatomic) BOOL childNeedsDisappeared;
@property (nonatomic) BOOL animatedForChildNeedsDisappeared;

// If the container gets rotated in the middle of a transition and the transition completes before the rotation does
// these properties will let us know we need to clean things up when the rotation is completed.
@property (nonatomic) BOOL rotationInterruptedTransition;
@property (nonatomic) BOOL transitionCompletedBeforeRotation;

@end



#pragma mark - Implementation

@implementation CLFContainerViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Container Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];

    _viewControllers = [NSMutableArray array];
    _animateWhenInsertingOrRemovingViewControllerAtCurrentIndex = YES;
    _preAnimateWhenInterruptingWithToTranistionToFromViewController = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.childNeedsDisappeared = NO;

    if (!self.appearedBefore) {
        // If there's a view controller available, and we haven't already switched to one, we'll put it on the screen.
        if (self.viewControllers.count && !self.childViewControllers.count)
            [self switchToViewController:self.viewControllers[0] animated:NO];
    }
    else if (!self.transitioning)
        [self.currentViewController beginAppearanceTransition:YES animated:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.appearedBefore)
        self.appearedBefore = YES;
    else if (!self.transitioning)
        [self.currentViewController endAppearanceTransition];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (!self.transitioning)
        [self.currentViewController beginAppearanceTransition:NO animated:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (self.transitioning) {
        self.childNeedsDisappeared = YES;
        self.animatedForChildNeedsDisappeared = animated;
    }
    else
        [self.currentViewController endAppearanceTransition];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (self.transitioning) {
        self.rotationInterruptedTransition = YES;
        self.transitionCompletedBeforeRotation = NO;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.rotationInterruptedTransition) {
        if (self.transitionCompletedBeforeRotation) {
            self.rotationInterruptionCleanupBlock();
            [self completeTransitionAndRemoveFromViewFromHierarchy:YES];
        }
        
        self.rotationInterruptedTransition = NO;
    }
}


- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}


- (void)dealloc
{
    [self unobserveNavItemContentsForViewController:_currentViewController];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters and Getters

- (CGRect)childRestingFrame
{
    return self.view.bounds;
}


- (void (^)())rotationInterruptionCleanupBlock
{
    return ^{
        self.currentViewController.view.frame = self.childRestingFrame;
        self.currentViewController.view.alpha = 1;
    };
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - VC Management

- (void)addViewController:(UIViewController *)viewController
{
    [_viewControllers addObject:viewController];
}


- (void)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    NSUInteger currentIndex = NSNotFound;
    
    if (self.viewControllers.count)
        currentIndex = [self.viewControllers indexOfObject:self.currentViewController];

    [_viewControllers insertObject:viewController atIndex:index];

    BOOL animated = self.animateWhenInsertingOrRemovingViewControllerAtCurrentIndex;

    if (index == currentIndex)
        [self switchToViewController:viewController animated:animated];
}


- (void)removeViewController:(UIViewController *)viewController
{
    if (self.currentViewController == viewController) {
        UIViewController *toViewController;

        if (self.viewControllers.count > 1) {
            NSUInteger index = [self.viewControllers indexOfObject:viewController];
            index += (index ? -1 : 1);

            toViewController = self.viewControllers[index];
        }

        BOOL animated = self.animateWhenInsertingOrRemovingViewControllerAtCurrentIndex;

        [self switchToViewController:toViewController animated:animated withCompletionBlock:^(BOOL finished) {
            [_viewControllers removeObject:viewController];
        }];
    }
    else
        [_viewControllers removeObject:viewController];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - VC Switching Simplified API

- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
           withCompletionBlock:(void (^)(BOOL))completionBlock
{
    [self switchToViewController:toViewController
                        animated:NO
               preAnimationSetup:nil
                      animations:nil
              animationDurations:nil
                animationOptions:nil
                 completionBlock:completionBlock];
}


- (void)switchToViewController:(UIViewController *)toViewController animated:(BOOL)animated
{
    [self switchToViewController:toViewController animated:animated withCompletionBlock:nil];
}


- (void)switchToViewControllerAtIndex:(NSUInteger)index
                             animated:(BOOL)animated
                  withCompletionBlock:(void (^)(BOOL))completionBlock
{
    UIViewController *toViewController = self.viewControllers[index];
    [self switchToViewController:toViewController animated:animated withCompletionBlock:completionBlock];
}


- (void)switchToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    UIViewController *toViewController = self.viewControllers[index];
    [self switchToViewController:toViewController animated:animated withCompletionBlock:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - VC Switching

- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
             preAnimationSetup:(void (^)())preAnimationSetup
                    animations:(NSArray *)animationBlocks
            animationDurations:(NSArray *)animationDurations
              animationOptions:(NSArray *)animationOptions
               completionBlock:(void (^)(BOOL))completionBlock
{
    NSParameterAssert(animationBlocks.count == animationDurations.count);
    NSParameterAssert(animationBlocks.count == animationOptions.count);

    UIViewController *fromViewController = self.currentViewController;
    if (fromViewController == toViewController)
        return;

    BOOL transitioningToCurrentFrom = (toViewController == self.transitionFromViewController) ? YES : NO;

    // End any transitions currently in progress.  If we're switching back to the current transitionFromViewController,
    // then we'll keep its view in the view hierarchy rather than remove and re-add it.  Otherwise we'd see it disappear
    // from the screen.
    [self completeTransitionAndRemoveFromViewFromHierarchy:(!transitioningToCurrentFrom)];

    [self registerTransitionFromViewController:fromViewController toViewController:toViewController animated:animated];

    if (!animationBlocks) {
        animationBlocks = @[ ^{} ];
        animated = NO;
    }
    if (!animated) {
        animationBlocks = @[ [animationBlocks lastObject] ];
        animationDurations = @[ @0 ];
        animationOptions = @[ @0 ];
    }

    BOOL preAnimate = YES;
    if (transitioningToCurrentFrom && !self.preAnimateWhenInterruptingWithToTranistionToFromViewController)
        preAnimate = NO;

    if (preAnimate && preAnimationSetup) preAnimationSetup();

    [self unobserveNavItemContentsForViewController:fromViewController];
    [self borrowNavItemContentsFromViewController:toViewController animated:animated];
    [self observeNavItemContentsForViewController:toViewController];

    [self runAnimationBlocks:animationBlocks
                   durations:animationDurations
                     options:animationOptions
             completionBlock:completionBlock];

    self.currentViewController = toViewController;
}


- (void)runAnimationBlocks:(NSArray *)animationBlocks
                 durations:(NSArray *)animationDurations
                   options:(NSArray *)animationOptions
           completionBlock:(void (^)(BOOL))completionBlock
{   
    NSParameterAssert(animationBlocks.count == animationDurations.count);
    NSParameterAssert(animationBlocks.count == animationOptions.count);
    
    [UIView animateWithDuration:[animationDurations[0] doubleValue]
                          delay:0
                        options:[animationOptions[0] integerValue]
                     animations:animationBlocks[0]
                     completion:^(BOOL finished) {
        // If there's more animations to run, run them
        if (animationBlocks.count > 1 && (finished || self.childNeedsDisappeared))
        {
            NSRange leftovers = NSMakeRange(1, animationBlocks.count - 1);
                             
            NSArray *leftoverBlocks = [animationBlocks subarrayWithRange:leftovers];
            NSArray *leftoverDurations = [animationDurations subarrayWithRange:leftovers];
            NSArray *leftoverOptions = [animationOptions subarrayWithRange:leftovers];

            [self runAnimationBlocks:leftoverBlocks
                           durations:leftoverDurations
                             options:leftoverOptions
                     completionBlock:completionBlock];
        }
        // Otherwise, finish up
        else {
            if (self.rotationInterruptedTransition)
                self.transitionCompletedBeforeRotation = YES;

            if (finished || self.childNeedsDisappeared)
                [self completeTransitionAndRemoveFromViewFromHierarchy:YES];
                            
            if (completionBlock) completionBlock(finished);

            if (self.childNeedsDisappeared) {
                [self.currentViewController beginAppearanceTransition:NO
                                                             animated:self.animatedForChildNeedsDisappeared];
                    
                [self.currentViewController endAppearanceTransition];
            }
        }
    }];
}


- (void)registerTransitionFromViewController:(UIViewController *)fromViewController
                            toViewController:(UIViewController *)toViewController
                                    animated:(BOOL)animated
{
    self.transitioning = YES;

    self.transitionToViewController = toViewController;
    self.transitionFromViewController = fromViewController;

    if (toViewController) {
        NSAssert([self.viewControllers containsObject:toViewController],
                 @"You cannot transition to a view controller that has not been added using addViewController:");

        if (![self.childViewControllers containsObject:toViewController])
            [self addChildViewController:toViewController];

        if (![self.view.subviews containsObject:toViewController.view])
            [self addViewFromViewController:toViewController];
    }

    [toViewController beginAppearanceTransition:YES animated:animated];
    [fromViewController beginAppearanceTransition:NO animated:animated];
}


- (void)completeTransitionAndRemoveFromViewFromHierarchy:(BOOL)removeFromViewFromHierarchy
{
    [self.transitionToViewController endAppearanceTransition];
    [self.transitionToViewController didMoveToParentViewController:self];
    self.transitionToViewController = nil;

    if (removeFromViewFromHierarchy)
        [self.transitionFromViewController.view removeFromSuperview];
    
    [self.transitionFromViewController endAppearanceTransition];
    [self.transitionFromViewController removeFromParentViewController];
    self.transitionFromViewController = nil;

    self.transitioning = NO;
}


- (void)addViewFromViewController:(UIViewController *)viewController
{
    UIView *view = viewController.view;
    view.frame = self.childRestingFrame;

    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [self.view insertSubview:view atIndex:0];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Navigation Items


- (void)borrowNavItemContentsFromViewController:(UIViewController *)vc animated:(BOOL)animated
{
    [self lendNavItemContentsFromViewController:vc toViewController:self animated:animated];
    [self lendNavItemContentsFromViewController:self toViewController:self.parentViewController animated:animated];
}


- (void)lendNavItemContentsFromViewController:(UIViewController *)fromVC
                             toViewController:(UIViewController *)toVC
                                     animated:(BOOL)animated
{
    UINavigationItem *toNavItem = toVC.navigationItem;
    UINavigationItem *fromNavItem = fromVC.navigationItem;

    toNavItem.title = fromNavItem.title;
    toNavItem.prompt = fromNavItem.prompt;

    toNavItem.backBarButtonItem = fromNavItem.backBarButtonItem;
    [toNavItem setHidesBackButton:fromNavItem.hidesBackButton animated:animated];

    toNavItem.leftItemsSupplementBackButton = fromNavItem.leftItemsSupplementBackButton;

    toNavItem.titleView = fromNavItem.titleView;

    [toNavItem setLeftBarButtonItems:fromNavItem.leftBarButtonItems animated:animated];
    [toNavItem setRightBarButtonItems:fromNavItem.rightBarButtonItems animated:animated];
}


- (NSArray *)navItemContentsToObserve
{
    return @[ @"title", @"prompt", @"backBarButtonItem", @"hidesBackButton", @"leftItemsSupplementBackButton",
              @"titleView", @"leftBarButtonItem", @"leftBarButtonItems", @"rightBarButtonItem",
              @"rightBarButtonItems" ];
}


- (void)observeNavItemContentsForViewController:(UIViewController *)vc
{
    UINavigationItem *navItem = vc.navigationItem;

    for (NSString *keyPath in [self navItemContentsToObserve])
        [navItem addObserver:self forKeyPath:keyPath options:0 context:(__bridge void *)self];
}


- (void)unobserveNavItemContentsForViewController:(UIViewController *)vc
{
    UINavigationItem *navItem = vc.navigationItem;

    for (NSString *keyPath in [self navItemContentsToObserve])
        [navItem removeObserver:self forKeyPath:keyPath context:(__bridge void *)self];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ((__bridge id)context == self) {
        [self borrowNavItemContentsFromViewController:self.currentViewController
                                             animated:self.animateNavItemBarButtonItemChanges];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
