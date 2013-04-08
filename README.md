# CLFContainerViewController

CLFContainerViewController is a UIViewController subclass that is designed to make the creation of custom container view controllers much easier.

When subclassing CLFContainerViewController to create your own custom container, you do not have to worry about managing the view controller hierarchy, or the view hierarchy. You also do not have to worry about forwarding appearance transition methods (like viewWillAppear, viewDidAppear, etc.) to your child view controllers. These details will all be handled by CLFContainerViewController, and will work properly even when the container itself is transitioned away from (so you are free to include containers in other containers without having to worry about how the transitions will be affected).

If your container is inside of a UINavigationController, the navigationItem properties will change accordingly as your container transitions between child view controllers.

You are given a powerful method for transitioning between view controllers with switchToViewController:animated:preAnimationSetup:animations:animationDurations:animationOptions:completionBlock:.

With this class, you can create container view controllers who's children occupy the entire bounds of the container. For example, your subclass could mimic a UINavigationController, a UITabBarController, or a UIPageViewController, though you are certainly not limited to recreating already existing containers.

This class, however, does not give you the ability to create a container view controller that displays multiple view controllers in different portions of the screen, like a UISplitViewController would.

## Subclassing the Subclasses

Two useful subclasses are included for you to further subclass, or to examine for examples of how to subclass CLFContainerViewController.

CLFStackContainerViewController implements a container view controller that functions as a stack with push and pop methods for adding and removing view controllers. You can also push and pop view controllers using segues. CLFStackPushSegue is provided for pushing view controllers onto the stack, and CLFStackPopSegue is automatically used for any unwind segues that occur in the container.

CLFTabbedContainerViewController implements a container view controller that functions similarly to a UITabBarController, although it does not include any UI for a tab bar (you could further implement such UI in your own subclass).

## Example Project

The example project further demonstrates subclassing CLFContainerViewController. With the exception of the UINavigationController that is used solely for its UINavigationBar, all of the containers in the example project are subclasses of CLFContainerViewController.

The MainViewController is a subclass of CLFTabbedContainerViewController, and adds the segmented control for switching between view controllers. It also manages the setup of the other containers.

The StackWithPopButtonViewController is a subclass of CLFStackContainerViewController, and adds a "Pop" button when you have view controllers pushed onto the stack.

The WobbleViewController is just a subclass of CLFContainerViewController. It's not a very practical container view controller in itself, but it does demonstrate the use of multiple animation blocks in a transition.

## Example Usage

You can implement a custom container by overriding as little as one method. For example, this container would transition between view controllers by first fading out the "from view controller" and then fading in the "to view controller".

```objective-c
@interface FadeOutThenInContainerViewController : CLFContainerViewController
@end

@implementation FadeOutThenInContainerViewController

- (void)switchToViewController:(UIViewController *)toViewController
                      animated:(BOOL)animated
           withCompletionBlock:(void (^)(BOOL finished))completionBlock
{
    void (^preAnimationSetup)() = ^{
        self.transitionToViewController.view.alpha = 0;
    };
    
    NSArray *animationBlocks = @[ ^{
        self.transitionFromViewController.view.alpha = 0;
    },
    { 
        self.transitionToViewController.view.alpha = 1;
    } ];
    
    NSArray *animationDurations = @[ @0.5, @0.5 ];
    NSArray *animationOptions =
        @[ @(UIViewAnimationOptionCurveEaseIn), @(UIViewAnimationOptionCurveEaseOut) ];
           
    [self switchToViewController:toViewController
                        animated:animated
               preAnimationSetup:preAnimationSetup
               		  animations:animationBlocks
              animationDurations:animationDurations
                animationOptions:animationOptions
                 completionBlock:completionBlock];
}


// We'll add some view controllers to our container in awakeFromNib.
// CLFContainerViewController will automatically put the first one on the screen
// in viewWillAppear.
//
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"ChildVC_1"];
    UIViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ChildVC_2"];
    UIViewController *vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"ChildVC_3"];
         
    
    [self addViewController:vc1];
    [self addViewController:vc2];
    [self addViewController:vc3];	
}


// For this example we'll assume we set up a segmented control for selecting view
// controllers in our storyboard.
//
- (IBAction)userTappedViewControllerSelection:(UISegmentedControl *)sender
{
    [self switchToViewControllerAtIndex:sender.selectedSegmentIndex animated:YES];
}

@end
```

## License Info
Released under an MIT License.

Copyright (c) 2013 Chris Flesner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
