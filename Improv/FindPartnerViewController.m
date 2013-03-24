//
//  FindPartnerViewController.m
//  Improv
//
//  Created by Ed Roman on 3/8/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "FindPartnerViewController.h"
#import "Parse/Parse.h"

@interface FindPartnerViewController ()

@end

@implementation FindPartnerViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonPressed:(id)sender {
}

- (IBAction)randomButtonPressed:(id)sender {
	// Get a random partner
	PFUser *invitee;
	PFQuery *query;
	NSArray *results = 0;
	do {
		query = [PFUser query];
		results = [query findObjects];
		invitee = results[rand() % results.count];
	} while ([invitee.objectId isEqualToString:[PFUser currentUser].objectId]);
	[self.game setObject:invitee forKey:@"invitee"];

	// Flip the current player
	PFUser *creator = [self.game objectForKey:@"creator"];
	PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
	[self.game setObject:partner forKey:@"currPlayer"];

	[self.game save];

	// Set all turns' partners
	query = [PFQuery queryWithClassName:@"Turn"];
	[query includeKey:@"Constraint"];
	[query whereKey:@"Game" equalTo:self.game];
	[query orderByAscending:@"turnNumber"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *turns, NSError *error) {
		if (!error)
		{
			NSLog(@"Successfully retrieved %d results.", turns.count);
			
			// For each turn...
			for (int i=0; i < turns.count; ++i)
			{
				PFObject *turn = turns[i];
				PFObject *user = [turn objectForKey:@"User"];
				// Set which player is assigned to this turn
				if (user.objectId == nil)
				{
					PFUser *turnUser = invitee;
					[turn setObject:turnUser forKey:@"User"];
					[turn saveInBackground];
				}
			}
		}
	}];
	
	////////////////////////////////////
	// Send Push Notification to partner
	////////////////////////////////////
	
	if (invitee.objectId != nil)
	{
		// Find devices (called "installations" in parse) associated with our partner
		PFQuery *userQuery = [PFUser query];
		[userQuery whereKey:@"objectId" equalTo:partner.objectId];
		PFQuery *pushQuery = [PFInstallation query];
		[pushQuery whereKey:@"owner" matchesQuery:userQuery];
		
		// Send push notification to query
		PFPush *push = [[PFPush alloc] init];
		[push setQuery:pushQuery]; // Set our Installation query
		[push setMessage:[NSString stringWithFormat:@"Hi %@!  %@ just started a story in A Tall Tale and would like to play with you!",
								[[PFUser currentUser] objectForKey:@"first_name"],
								[partner objectForKey:@"first_name"]]];
		[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded) {
				NSLog(@"Sent push notification!");
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Notification Error!"
																				message:[NSString stringWithFormat:@"Error sending a notification! %@", error]
																			  delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
				[alert show];
				NSLog(@"Error sending push: %@", error);
			}
		}];
	}

	[self performSegueWithIdentifier:@"FindPartnerToLobbyViewSegue" sender:sender];
}
@end
