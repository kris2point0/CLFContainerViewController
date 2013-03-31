//
//  MainViewController.h
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

#import "CLFTabbedContainerViewController.h"

/*
 * This subclass of CLFTabbedContainerViewController is also the primary view
 * controller for this project.
 *
 * It adds a segmented control, that is used for switching between the
 * Stack container and the Wobbler container.
 *
 * It also manages the setup of both the Stack and Wobbler containers.
 */


#pragma mark - Constants

// Set this to YES, and turn on Slow Animations in the simulator, then play
// around with the transitions in this example project.
//
// Notice that when viewWillDisappear is sent to a container, any transitions
// in progress with continue with their progress.
//
// When viewDidDisappear is sent to a container, any transitions in progress
// will be immediately wrapped up.
//
#define ANIMATE_TRANSITIONS_BETWEEN_STACK_AND_WOBBLER   NO



#pragma mark - Public Interface

@interface MainViewController : CLFTabbedContainerViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *vcSelectionControl;

@end
