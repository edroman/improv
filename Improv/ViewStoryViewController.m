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

- (void)clearView
{
	////////////////////////////////////////////
	// Clear the view, so user isn't presented with stand-in text
	////////////////////////////////////////////
	
	UILabel *partnerLabel = (UILabel *)[self.view viewWithTag:100];
	partnerLabel.text = @"";
	UILabel *storyLabel = (UILabel *)[self.view viewWithTag:101];
	storyLabel.text = @"";
	UILabel *voteLabel = (UILabel *)[self.view viewWithTag:102];
	voteLabel.text = @"";
}

- (void)showIcon
{
	////////////////////////////////////////////
	// Show "Waiting" icon
	////////////////////////////////////////////
	
	self.waitingIcon = [[UIAlertView alloc] initWithTitle:@"Please Wait..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
	[self.waitingIcon show];
	
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(self.waitingIcon.bounds.size.width / 2,
											 self.waitingIcon.bounds.size.height - 50);
	[indicator startAnimating];
	[self.waitingIcon addSubview:indicator];
}

- (void)hideIcon
{
	[self.waitingIcon dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self clearView];
	
	[self showIcon];
	
	// Get the main thread task queue.  More useful than a custom queue since we will
	// perform dialog box dismissal which can't be done unless you're on the main queue.
	dispatch_queue_t queue;
	queue = dispatch_get_main_queue();
//	queue = dispatch_queue_create("com.ghostfire.queue", NULL);

	////////////////////////////////////////////
	// BEGIN Compose the existing story so far
	////////////////////////////////////////////
	
	// Find the spine prefixes for this spine
	PFQuery *spinePrefixQuery = [PFQuery queryWithClassName:@"SpinePrefix"];
	[spinePrefixQuery whereKey:@"Spine" equalTo:[self.game objectForKey:@"spine"]];
	[spinePrefixQuery orderByAscending:@"turnNumber"];
	__block NSArray *spinePrefixes = 0;
	dispatch_async(queue, ^{
		spinePrefixes = [spinePrefixQuery findObjects];
	});
	
	// Figure out which user is our partner, then display his name
	PFUser *creator = [self.game objectForKey:@"creator"];
	PFUser *invitee = [self.game objectForKey:@"invitee"];
	PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
	UILabel *partnerLabel = (UILabel *)[self.view viewWithTag:100];
	partnerLabel.text = [NSString stringWithFormat:@"Game with %@", [partner objectForKey:@"name"]];
	
	NSMutableString *story = [[NSMutableString alloc] init];
	UILabel *storyLabel = (UILabel *)[self.view viewWithTag:101];
	NSString *intro = [[self.game objectForKey:@"intro"] objectForKey:@"value"];
	int turn = [[self.game objectForKey:@"currTurnNumber"] intValue];
	
	if (turn >= 2) {
		// Add the intro
		[story appendString:intro];
		
		// Find all turns for this game
		dispatch_async(queue, ^{
			PFQuery *query = [PFQuery queryWithClassName:@"Turn"];
			[query whereKey:@"Game" equalTo:self.game];
			[query orderByAscending:@"turnNumber"];
			NSArray *turns = [query findObjects];
			
			NSLog(@"Successfully retrieved %d results.", turns.count);
			
			// For each turn, add that turn's story spine + turn text
			int currTurnNumber = [[self.game objectForKey:@"currTurnNumber"] intValue];
			for (int i=0; i < currTurnNumber-1; ++i) {
				// Add story spine (not for first, since that is the intro)
				if (i >= 1)
				{
					// Set spine prefix
					PFObject *spinePrefix = spinePrefixes[i];
					NSString *spinePrefixStr = [spinePrefix objectForKey:@"prefix"];
					[story appendString:spinePrefixStr];
					
					// Add space after spine
					[story appendString:@" "];
				}
				
				// Add turn
				NSString *turn = [turns[i] objectForKey:@"turn"];
				[story appendString:turn];
				
				// Add space after turn
				[story appendString:@" "];
			}
			
			// Update label
			storyLabel.text = story;
		});
	}
	else {
		storyLabel.text = @"";
	}
	
	////////////////////////////////////////////
	// END Compose the existing story so far
	////////////////////////////////////////////
	
	// Display votes
	UILabel *voteLabel = (UILabel *)[self.view viewWithTag:102];
	int votes = [[_game objectForKey:@"votes"] intValue];
	voteLabel.text = [NSString stringWithFormat:(votes == 1 ? @"%d vote" : @"%d votes"), votes];

	// Check to see if we've voted already, so that we don't allow multiple votes
	dispatch_async(queue, ^{
		PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
		[query whereKey:@"Game" equalTo:self.game];
		[query whereKey:@"User" equalTo:[PFUser currentUser]];
		NSArray *votes = [query findObjects];
		if (votes.count != 0) {
			UIButton *voteButton = (UIButton *)[self.view viewWithTag:103];
			voteButton.hidden = YES;
		}
	});
	
	//////////////////////////////////////////
	// Dismiss loading icon after all async tasks are done
	//
	// Note that UI tasks must be done on the main thread,
	// so this works because we're using the main thread queue
	//////////////////////////////////////////
	
	dispatch_async(queue, ^{
		[self hideIcon];
	});
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookPostToWall:(id)sender
{
	// TODO: Custom URL to ATallTale.com
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//											 @"http://www.ATallTale.com", @"link",
//											 @"Check out this tall tale!", @"name",
//											 @"Made by XYZ and ABC on http://www.aTallTale.com", @"caption",
//											 @"Once upon a time...", @"description",
											 @"I made a really entertaining story with my friend.  Check it out!  Would you please help me by voting for it?  http://www.ATallTale.com", @"message",
											 nil];

   // Create request for user's Facebook data.  Does NOT use a dialog box, which is nice.
	// Unfortuantely no way to @mention another user in these posts.
	//
	// Note: Can only post to your own wall using this technique.
	// When posting to friends walls it requires a dialog box -- see NewStoryViewController.m
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

- (IBAction)VoteAction:(id)sender {
	
	// Check to see if we've voted already, so that we don't allow multiple votes
	PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
	[query whereKey:@"Game" equalTo:self.game];
	[query whereKey:@"User" equalTo:[PFUser currentUser]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		// If we've already voted
		if (objects.count != 0)
		{
			// Pop-up box
			UIAlertView *alert = [[UIAlertView alloc]	initWithTitle:@"Duplicate vote!"
																			message:@"You already voted for this story!"
																		  delegate:nil
															  cancelButtonTitle:@"OK"
															  otherButtonTitles:nil];
			[alert show];
		}
		else
		{
			// Increment vote, save game
			int votes = [[self.game objectForKey:@"votes"] intValue];
			votes += 1;
			[self.game setObject:[NSNumber numberWithInt:votes] forKey:@"votes"];
			[self.game save];
			
			// Add new vote
			PFObject *vote = [PFObject objectWithClassName:@"Vote"];
			[vote setObject:self.game forKey:@"Game"];
			[vote setObject:[PFUser currentUser] forKey:@"User"];
			[vote save];
			
			// Pop-up box
			UIAlertView *alert = [[UIAlertView alloc]	initWithTitle:@"Vote cast!"
																			message:@"You voted for this story!"
																		  delegate:nil
															  cancelButtonTitle:@"OK"
															  otherButtonTitles:nil];
			[alert show];

			// Hide vote button
			UIButton *voteButton = (UIButton *)[self.view viewWithTag:103];
			voteButton.hidden = YES;
			
			// Update vote count
			UILabel *voteLabel = (UILabel *)[self.view viewWithTag:102];
			voteLabel.text = [NSString stringWithFormat:(votes == 1 ? @"%d vote" : @"%d votes"), votes];
		}
	}];

	
	// TODO: Refresh view so we see updated vote count
	
}
@end
