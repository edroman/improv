//
//  IntroPageViewController.h
//  Improv
//
//  Created by Ed Roman on 1/27/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>

// Represents a single page of content within the IntroViewController.  There are N of these.
@interface IntroPageViewController : UIViewController

- (id)initWithPageIndex:(NSUInteger)index;
- (void) setIndex:(NSUInteger)index;
- (NSInteger)pageIndex;
- (IBAction)pressedButton:(id)sender;

@end
