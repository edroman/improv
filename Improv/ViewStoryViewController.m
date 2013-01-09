//
//  ViewStoryViewController.m
//  Improv
//
//  Created by Ed Roman on 1/8/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "ViewStoryViewController.h"
#import <Parse/Parse.h>

@interface ViewStoryViewController ()

@end

@implementation ViewStoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view.

	UILabel *playerLabel = (UILabel *)[self.view viewWithTag:100];
	PFUser *obj = [_game objectForKey:@"creator"];
	NSString *str = [obj objectForKey:@"name"];
	PFUser *obj2 = [_game objectForKey:@"invitee"];
	NSString *str2 = [obj2 objectForKey:@"name"];
	playerLabel.text = [NSString stringWithFormat:@"By %@ and %@", str, str2];

	UILabel *storyLabel = (UILabel *)[self.view viewWithTag:101];
	storyLabel.text = @"It was a dark and stormy night...";		 // TODO
	
	UILabel *voteLabel = (UILabel *)[self.view viewWithTag:102];
	int votes = [[_game objectForKey:@"votes"] intValue];
	voteLabel.text = [NSString stringWithFormat:@"%d votes", votes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
