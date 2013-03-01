//
//  Utils.m
//  Improv
//
//  Created by Ed Roman on 2/20/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "Utils.h"

@interface Utils ()
@end

static UIAlertView *waitingIcon = 0;

@implementation Utils

+ (void)showIcon
{
	////////////////////////////////////////////
	// Show "Waiting" icon
	////////////////////////////////////////////
	
	waitingIcon = [[UIAlertView alloc] initWithTitle:@"Please Wait..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
	[waitingIcon show];
	
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(waitingIcon.bounds.size.width / 2,
											 waitingIcon.bounds.size.height - 50);
	[indicator startAnimating];
	[waitingIcon addSubview:indicator];
}

+ (void)hideIcon
{
	[waitingIcon dismissWithClickedButtonIndex:0 animated:YES];
}

@end
