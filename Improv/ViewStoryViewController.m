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

- (IBAction)facebookPostToWall:(id)sender
{
	/*
	 NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	 kAppId, @"app_id",
	 @"https://developers.facebook.com/docs/reference/dialogs/", @"link",
	 @"http://fbrell.com/f8.jpg", @"picture",
	 @"Facebook Dialogs", @"name",
	 @"Reference Documentation", @"caption",
	 @"Using Dialogs to interact with users.", @"description",
	 nil];
	 
	 [_facebook dialog:@"feed" andParams:params andDelegate:self];
	 */

	//	[PFFacebookUtils session]

	/*

		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:4];

		[variables setObject:@"http://farm6.static.flickr.com/5015/5570946750_a486e741.jpg" forKey:@"link"];
		[variables setObject:@"http://farm6.static.flickr.com/5015/5570946750_a486e741.jpg" forKey:@"picture"];
		[variables setObject:@"You scored 99999" forKey:@"name"];
		[variables setObject:@" " forKey:@"caption"];
		[variables setObject:@"Download my app for the iPhone NOW." forKey:@"description"];

		FbGraphResponse *fb_graph_response = [fbGraph doGraphPost:@"me/feed" withPostVars:variables];
		NSLog(@"postMeFeedButtonPressed:  %@", fb_graph_response.htmlResponse);

		//parse our json
		SBJSON *parser = [[SBJSON alloc] init];
		NSDictionary *facebook_response = [parser objectWithString:fb_graph_response.htmlResponse error:nil];
		[parser release];
	*/

	// TODO: Fix
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"http://www.ATallTale.com", @"link",
											 @"Check out this tall tale!", @"name",
											 @"Made by XYZ and ABC on http://www.aTallTale.com", @"caption",
											 @"Once upon a time...", @"description",
//											 @"Test Message!", @"message",
											 nil];

   // Create request for user's Facebook data
	NSString *requestPath = @"/me/feed";
	
	// if (![facebook isSessionValid]) { [facebook authorize:nil]; }
	
	// Send request to Facebook
	PF_FBRequest *request = [PF_FBRequest requestWithGraphPath:requestPath parameters:params HTTPMethod:@"POST"];
	[request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
		if (!error) {
			NSLog(@"Post to Facebook successful!");
		}
		else if ([error.userInfo[PF_FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
			
			NSLog(@"OauthException: %@", error);
			
			// TODO: Logout, using something like [self logoutButtonTouchHandler:nil];
		} else {
			NSLog(@"Some other error: %@", error);
		}
	}];


}

- (void)facebookGetInfo
{
   // Create request for user's Facebook data
	NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status";
	
	// Send request to Facebook
	PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
	[request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
		if (!error) {
			/*
			NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary

			NSString *facebookId = userData[@"id"];
			NSString *name = userData[@"name"];
			NSString *location = userData[@"location"][@"name"];
			NSString *gender = userData[@"gender"];
			NSString *birthday = userData[@"birthday"];
			NSString *relationship = userData[@"relationship_status"];
			*/
			// Now add the data to the UI elements
			// ...
		}
		else if ([error.userInfo[PF_FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {

			NSLog(@"The facebook session was invalidated");
			
			// TODO: Logout, using soemething like [self logoutButtonTouchHandler:nil];
		} else {
			NSLog(@"Some other error: %@", error);
		}
	}];
}

@end
