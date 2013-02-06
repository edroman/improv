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

	// Figure out which user is our partner, then display his name
	PFUser *creator = [self.game objectForKey:@"creator"];
	PFUser *invitee = [self.game objectForKey:@"invitee"];
	PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
	UILabel *partnerLabel = (UILabel *)[self.view viewWithTag:100];
	partnerLabel.text = [NSString stringWithFormat:@"Game with %@", [partner objectForKey:@"name"]];
	
	////////////////////////////////////////////
	// BEGIN Compose the existing story so far
	////////////////////////////////////////////
	
	NSMutableString *story = [[NSMutableString alloc] init];
	UILabel *storyLabel = (UILabel *)[self.view viewWithTag:101];
	NSString *intro = [[self.game objectForKey:@"intro"] objectForKey:@"value"];
	int turn = [[self.game objectForKey:@"turn"] intValue];
	
	if (turn >= 2) {
		// Add the intro
		[story appendString:intro];
		
		// Find all turns for this game
		PFQuery *query = [PFQuery queryWithClassName:@"Turn"];
		[query whereKey:@"Game" equalTo:self.game];
		[query orderByAscending:@"turnNumber"];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				// The find succeeded.
				NSLog(@"Successfully retrieved %d results.", objects.count);
				
				// For each turn, add that turn's story spine + turn text
				for (int i=0; i < objects.count; ++i) {
					// Add story spine (not for first, since that is the intro)
					if (i >= 1)
					{
						NSString *str = [NSString stringWithFormat:@"prefix%d", i];
						NSString *spine = [[self.game objectForKey:@"spine"] objectForKey:str];
						[story appendString:spine];

						// Add space after spine
						[story appendString:@" "];
					}
					
					// Add turn
					NSString *turn = [objects[i] objectForKey:@"turn"];
					[story appendString:turn];

					// Add space after turn
					[story appendString:@" "];
				}
				
				// Update label
				storyLabel.text = story;
			} else {
				// Log details of the failure
				NSLog(@"Error: %@ %@", error, [error userInfo]);
			}
		}];
	}
	else {
		storyLabel.text = @"";
	}
	
	////////////////////////////////////////////
	// END Compose the existing story so far
	////////////////////////////////////////////

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
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"http://www.ATallTale.com", @"link",
											 @"Check out this tall tale!", @"name",
											 @"Made by XYZ and ABC on http://www.aTallTale.com", @"caption",
											 @"Once upon a time...", @"description",
//											 @"Test Message!", @"message",
											 nil];

   // Create request for user's Facebook data
	NSString *requestPath = @"/me/feed";
	
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
