//
//  CLFContainerViewController.h
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

#import <UIKit/UIKit.h>

/*
 * This class is designed to make it much easier to create custom container view controllers, and is meant to be 
 * subclassed to do just that.
 *
 * In your subclasses you will not need to worry about adding or removing any view controllers from the view controller
 * hierarchy, or adding or removing any of the child view controller's views from the view hierarchy. That is all
 * handled internally by this class.
 *
 * This class will also handle all sending of appearance transition methods such as viewWillAppear, viewDidAppear, etc.
 * to all of the child view controllers, including during transitions to and from your container view controller.
 * (So you are free to include containers in containers).
 *
 * The method switchToViewController:animated:preAnimationSetup:animations:animationDurations:animationOptions:
 * completionBlock: is provided to allow you a great amount of flexibility in providing custom transitions between view\
 * controllers.
 *
 * What you can do with this class is create container view controllers who's children occupy the entire bounds of the
 * container. For example, your subclass could mimic a UINavigationController, a UITabBarController, or a
 * UIPageViewController. However, you are certainly not limited to recreating already existing containers.
 *
 * What you cannot do with this class is create a container view controller that displays multiple view controllers in
 * different portions of the screen, like a UISplitViewController would.
 */


#pragma mark - Public Interface

@interface CLFContainerViewController : UIViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

// The array of view controllers that this container is currently managing. View controllers are added to this array
// using addViewController:, or insertViewController:atIndex:, and removed using removeViewController:.
//
// Trying to transition to a view controller that is not in this array will raise an exception.
//
// Note: Adding a view controller to this array does not present it, or prepare to present it on the screen. It simply
// adds it to the list of view controllers being managed by this container.
//
@property (readonly, nonatomic) NSArray *viewControllers;

// The view controller that is currently on screen or is currently being transitioned to.
@property (readonly, nonatomic) UIViewController *currentViewController;

// Returns whether or not a transition between view controllers is currently in progress.
@property (readonly, nonatomic) BOOL transitioning;


// When borrowNavItemContentsFromChildren is YES (the default), this class uses key-value observing to determine when
// changes are made to self.currentViewController's navigationItem's contents. Unfortunately, using this approach means
// that changing the barButtonItems with a method that animates the change (for example setLeftBarButtonItems:animated:)
// will not honor the animated BOOL.
//
// As a workaround, this property is provided to give you the opportunity to animate those changes.
//
// The default is NO.
//
@property (nonatomic) BOOL borrowNavItemContentsFromChildren;
@property (nonatomic) BOOL animateNavItemBarButtonItemChanges;


// This property determines the frame that will be used for child view controllers in a non-transitioning state. Unless
// overriden by your subclass it will return self.containerView.bounds
@property (readonly, nonatomic) CGRect childRestingFrame;

// This property determines the view into which child view controller's view should be inserted as subview.
// This could be convenient if container controller manages somewhat complex layout.
// Unless overriden by your subclass is self.view
@property (readonly, nonatomic) UIView *containerView;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties that should only be used by subclasses

// When a transition is in progress, these are the two view controllers involved.
//
// In your subclass, reference these two view controllers in your preAnimationSetup block, and your animationBlocks
// when calling switchToViewController:animated:preAnimationSetup:animations:animationDurations:
// animationOptions:completionBlock:.
//
@property (readonly, nonatomic) UIViewController *transitionFromViewController;
@property (readonly, nonatomic) UIViewController *transitionToViewController;

// This property determines whether or not the transition will be animated if insertViewController:atIndex: is called
// with the current index, or if removeViewController: is called with the current view controller.
//
// The default is YES.
//
@property (nonatomic) BOOL animateWhenInsertingOrRemovingViewControllerAtCurrentIndex;

// Interrupting a transition with a new transition who's toViewController is the same as the current transition's
// fromViewController will sometimes produce better animations if the preAnimationSetup block is ignored in the
// interrupting transition. With this property set to YES, the preAnimationSetup block will always be run for every
// transition. With the property set to NO, the preAnimationSetup block will be skipped in the above mentioned
// situation.
//
// The default is YES.
//
@property (nonatomic) BOOL preAnimateWhenInterruptingWithToTranistionToFromViewController;

// If a rotation is started on the container in the middle of a transition, and the transition completes before the
// rotation completes, it can leave the transition stuck somewhere in the middle of the animation. This block will be
// run in that situation to clean up the mess.
//
// The default implementation is as follows:
//
// - (void (^)())rotationInterruptionCleanupBlock
// {
//     return ^{
//         self.currentViewController.view.frame = self.childRestingFrame;
//         self.currentViewController.view.alpha = 1;
//     };
// }
//
// The default should suffice for most transitions, but the property is included here to give you a chance to override
// it for your container's situation if need be.
//
@property (readonly, nonatomic) void (^rotationInterruptionCleanupBlock)();


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Adding and Removing View Controllers

// These methods add or remove view controllers from the viewControllers array.

- (void)addViewController:(UIViewController *)viewController;
- (void)insertViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)removeViewController:(UIViewController *)viewController;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching View Controllers Simplified API

// These methods exist to give your subclass a simplified API for switching view controllers.  Your subclass is not
// required to support this API, and may instead use its own methods for triggering transitions. For example,
// a stack-like controller may implement push and pop methods rather than supporting this API.
//
// The default implementation of these methods is to switch view controllers with no animation.
//
// To support the API, subclasses only need to override switchToViewController:animated:withCompletionBlock:
// and have it call switchToViewController:preAnimationSetup:animated:animations:animationOptions:animationsDurations:
// completionBlock:
//
// The rest of the switchToViewController methods will call the subclass' implementation of
// switchToViewController:animated:withCompletionBlock: automatically.
//
- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
           withCompletionBlock:(void (^)(BOOL finished))completionBlock;

- (void)switchToViewController:(UIViewController *)toViewController animated:(BOOL)animated;

- (void)switchToViewControllerAtIndex:(NSUInteger)index
                             animated:(BOOL)animated
                  withCompletionBlock:(void (^)(BOOL finished))completionBlock;

- (void)switchToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching View Controllers API

// When you are subclassing switchToViewController:animated:withCompletionBlock: or creating your own methods for
// transitioning you will want to call this method to handle the actual transition.
//
// In the preAnimationSetup block, and the animationBlocks, reference self.transitionToViewController, and
// self.transitionFromViewController and do your animations with those.
//
// Do not reference those properties in the completionBlock, as they will either be nil (if your transition completed),
// or they will be assigned to the interrupting transition's view controllers (if your transition was interrupted
// early).
//
// You probably won't need to override this method due to all the blocks that you can send it. However, if you must
// override it, be sure to call super in your implementation.
//
- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
             preAnimationSetup:(void (^)())preAnimationSetup
                    animations:(NSArray *)animationBlocks
            animationDurations:(NSArray *)animationDurations
              animationOptions:(NSArray *)animationOptions
               completionBlock:(void (^)(BOOL finished))completionBlock;

@end
