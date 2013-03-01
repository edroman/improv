//
//  ViewStoryViewController.h
//  Improv
//
//  Created by Ed Roman on 1/8/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewStoryViewController : UIViewController

@property (nonatomic, strong) PFObject *game;
- (IBAction)VoteAction:(id)sender;
@property (nonatomic, strong) UIAlertView *waitingIcon;

@end
