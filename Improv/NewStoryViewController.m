//
//  NewStoryViewController.m
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "NewStoryViewController.h"
#import <Parse/Parse.h>

@interface NewStoryViewController ()

@end

@implementation NewStoryViewController

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

// Triggered when user clicks "random".
// Prepares for the transition to a new game, but beforeso, pairs user up with a random user.
//
// This could later be smarter about re-activing old users while
// balancing the experience for new users.  Could cycle via push notifications between users until
// someone responds, and then begin a game with that pair.
//
// TODO: need to have user be urged to accept push notifications somewhere.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier compare:@"RandomToPlayStorySegue"] == 0) {
		NSArray *results = 0;

		// TODO: Ask parse for a random user (not same as self)
		PFQuery *query;
		
		query = [PFUser query];
		[query whereKey:@"playerName" equalTo:@"Harvey Dent"];
		results = [query findObjects];
		PFUser *invitee = results[(rand() % results.count) - 1];

		// TODO: Get a random intro
		query = [PFQuery queryWithClassName:@"Intro"];
		results = [query findObjects];
		NSObject *intro = results[(rand() % results.count) - 1];
	
		// TODO: Create an empty new game with the 2 players
		PFObject *game = [PFObject objectWithClassName:@"Game"];
		[game setObject:false forKey:@"completed"];
		[game setObject:0 forKey:@"votes"];
		[game setObject:[PFUser currentUser] forKey:@"creator"];
		[game setObject:invitee forKey:@"invitee"];
		[game setObject:intro forKey:@"intro"];
		[game save];
	
		// TODO: Forward the player to the screen to start the game
	}
}
@end
