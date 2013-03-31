//
//  CLFStackContainerViewController.h
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

/*
 * This subclass of CLFContainerViewController is meant to give you a starting
 * point for creating stack-like view controller containers.
 *
 * The switchToViewController:animated:preAnimationSetup:animations:
 * animationDurations:animationOptions:completionBlock: method has been replaced
 * by the pushViewController:animated:preAnimationSetup:animations:
 * animationDurations:animationOptions:completionBlock, and the
 * popToViewController:animated:preAnimationSetup:animations:animationDurations
 * animationOptions:completionBlock methods.
 *
 * This class also disables the addViewController: and removeViewController:
 * methods, and instead automatically manages the viewControllers array from
 * within the push and pop methods.
 */


#pragma mark - Types

typedef NS_ENUM(NSUInteger, CLFStackContainerPushPopDirections) {
    CLFStackContainerPushUpPopDown,
    CLFStackContainerPushDownPopUp,
    CLFStackContainerPushLeftPopRight,
    CLFStackContainerPushRightPopLeft
};



#pragma mark - Public Interface

@interface CLFStackContainerViewController : CLFContainerViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

@property (readonly, nonatomic) UIViewController *rootViewController;
@property (readonly, nonatomic) UIViewController *topViewController;

// The default implementation uses this property to determine which
// animations to use for the pushes and pops.
//
// Your subclass is free to ignore this property in its own transitions.
@property (nonatomic) CLFStackContainerPushPopDirections transitionDirections;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties that should only be used by subclasses

// Your subclass can optionally add these blocks to the blocks they send
// pushViewController:animated:preAnimationSetup:animations:...
// and popToViewController:animated:preAnimationSetupa:animations:....
//
// Ex.
// void (^preAnimationSetup)() = ^{
//     NSLog(@"Preparing to transition upwards");
//     self.transitionUpPreAnimationBlock();
// };
//
// NSArray *animations = @[ ^{
//     NSLog(@"Transitioning upwards");
//     void (^transitionUpBlock)() = self.transitionUpAnimationBlocks[0];
//     transitionUpBlock();
// } ];
//
// Your subclass is free to override these properties to provide custom
// transitions that work with the transitionDirections property.
//
@property (readonly, nonatomic) void (^transitionUpPreAnimationBlock)();
@property (readonly, nonatomic) NSArray *transitionUpAnimationBlocks;
@property (readonly, nonatomic) NSArray *transitionUpAnimationDurations;
@property (readonly, nonatomic) NSArray *transitionUpAnimationOptions;

@property (readonly, nonatomic) void (^transitionDownPreAnimationBlock)();
@property (readonly, nonatomic) NSArray *transitionDownAnimationBlocks;
@property (readonly, nonatomic) NSArray *transitionDownAnimationDurations;
@property (readonly, nonatomic) NSArray *transitionDownAnimationOptions;

@property (readonly, nonatomic) void (^transitionLeftPreAnimationBlock)();
@property (readonly, nonatomic) NSArray *transitionLeftAnimationBlocks;
@property (readonly, nonatomic) NSArray *transitionLeftAnimationDurations;
@property (readonly, nonatomic) NSArray *transitionLeftAnimationOptions;

@property (readonly, nonatomic) void (^transitionRightPreAnimationBlock)();
@property (readonly, nonatomic) NSArray *transitionRightAnimationBlocks;
@property (readonly, nonatomic) NSArray *transitionRightAnimationDurations;
@property (readonly, nonatomic) NSArray *transitionRightAnimationOptions;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initial Setup

// Set the root view controller. This method can only be called once,
// and it must be called before you will be able to push any additional view
// controllers.
- (void)setupWithRootViewController:(UIViewController *)rootViewController;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pushing and Popping View Controllers Simplified API

// These methods give your subclass a simplified API for pushing and popping
// view controllers.
//
// If you want to override these methods in your subclass, you only need to
// override pushViewController:animated: and popToViewController:animated:.
// The other two pop methods will call popToViewController:animated:
// automatically.
//
// You may not need to override these methods however, since you can already
// provide custom transition animations with the properties that provide
// the animation information.
//
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

- (NSArray *)popToViewController:(UIViewController *)viewController
                                 animated:(BOOL)animated;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pushing and Popping View Controllers API

// If you subclass pushViewController:animated:, call this method to handle
// the actual transition.
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
         preAnimationSetup:(void (^)())preAnimationSetup
                animations:(NSArray *)animationBlocks
        animationDurations:(NSArray *)animationDurations
          animationOptions:(NSArray *)animationOptions
           completionBlock:(void (^)(BOOL finished))completionBlock;

// If you subclass popToViewController:animated:, call this method to handle
// the actual transition.
- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated
               preAnimationSetup:(void (^)())preAnimationSetup
                      animations:(NSArray *)animationBlocks
              animationDurations:(NSArray *)animationDurations
                animationOptions:(NSArray *)animationOptions
                 completionBlock:(void (^)(BOOL finished))completionBlock;



@end
