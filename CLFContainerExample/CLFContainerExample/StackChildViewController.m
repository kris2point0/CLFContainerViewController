//
//  StackChildViewController.m
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

#import "StackChildViewController.h"


#pragma mark - Private Interface

@interface StackChildViewController ()

@property (readonly, nonatomic) NSArray *colorNames;

@end



#pragma mark - Implementation

@implementation StackChildViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    srand(time(NULL));

    self.view.backgroundColor = self.color;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters and Getters

- (CLFStackContainerViewController *)stackController
{
    CLFStackContainerViewController *stackController;

    if ([self.parentViewController
         isKindOfClass:[CLFStackContainerViewController class]])
    {
        stackController =
            (CLFStackContainerViewController *)self.parentViewController;
    }

    return stackController;
}


- (NSArray *)colorNames
{
    return @[ @"red", @"green", @"blue", @"cyan", @"yellow", @"magenta",
              @"orange", @"purple", @"brown" ];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Add Color Button

- (IBAction)userTappedAddRandomColorToStack:(UIButton *)sender
{
    NSMutableArray *colorNames = [self.colorNames mutableCopy];
    NSString *currentColorName = [self.title lowercaseString];
    [colorNames removeObject:currentColorName];

    NSString *randomColorName = colorNames[rand() % colorNames.count];

    NSString *colorSelectorName =
        [randomColorName stringByAppendingString:@"Color"];
    SEL colorSelector = NSSelectorFromString(colorSelectorName);
    UIColor *color = [UIColor performSelector:colorSelector];

    NSString *title = [randomColorName capitalizedString];

    StackChildViewController *newViewController =
        [self.storyboard
         instantiateViewControllerWithIdentifier:@"StackChildVC"];
    
    newViewController.color = color;
    newViewController.title = title;

    [self.stackController pushViewController:newViewController animated:YES];
}

@end
