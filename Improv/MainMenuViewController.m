//
//  MainMenuViewController.m
//  Improv
//
//  Created by Ed Roman on 1/8/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "MainMenuViewController.h"
#import "Parse/Parse.h"
#import "PlayStoryViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

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

// Triggered when user clicks "new".
// Prepares for the transition to a new game, but beforeso, pairs user up with a random user.
//
// This could later be smarter about re-activing old users while
// balancing the experience for new users.  Could cycle via push notifications between users until
// someone responds, and then begin a game with that pair.
//
// TODO: need to have user be urged to accept push notifications somewhere.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier compare:@"LobbyToNewStorySegue"] == 0) {
		NSArray *results = 0;
		
		// TODO: Defer the partner linkage until after the user has invested in a new story
		// by moving just that part into FindPartnerViewController
		
		// TODO: Ask parse for a random user (not same as self).
		// The algorithm below works but it gets ALL users, so no good
		// See https://parse.com/questions/is-it-possible-to-query-for-a-random-object
		
		PFQuery *query;
		
		// Get a random partner
		PFUser *invitee;
		do {
			query = [PFUser query];
			results = [query findObjects];
			invitee = results[rand() % results.count];
		}
		while ([invitee.objectId isEqualToString:[PFUser currentUser].objectId]);
		
		// Get a random intro
		query = [PFQuery queryWithClassName:@"Intro"];
		results = [query findObjects];
		PFObject *intro = results[rand() % results.count];
		
		// Get a random story spine
		query = [PFQuery queryWithClassName:@"Spine"];
		[query whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
		results = [query findObjects];
		PFObject *spine = results[rand() % results.count];
		int numTurns = [[spine objectForKey:@"numTurns"] intValue];
		
		// Create an empty new game with the 2 players
		PFObject *game = [PFObject objectWithClassName:@"Game"];
		[game setObject:[NSNumber numberWithBool:false] forKey:@"completed"];
		[game setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
		[game setObject:[NSNumber numberWithInt:1] forKey:@"currTurnNumber"];
		[game setObject:[PFUser currentUser] forKey:@"creator"];
		[game setObject:invitee forKey:@"invitee"];
		[game setObject:intro forKey:@"intro"];
		[game setObject:spine forKey:@"spine"];
		[game setObject:[PFUser currentUser] forKey:@"currPlayer"];
		
		// Persist game via Parse
		[game save];
		
		//////////////////////////////////////////////
		// Create turns in Parse w/Constraints
		//////////////////////////////////////////////
		
		// Find the spine prefixes for this spine
		PFQuery *spinePrefixQuery = [PFQuery queryWithClassName:@"SpinePrefix"];
		[spinePrefixQuery includeKey:@"Constraint_Category"];
		[spinePrefixQuery whereKey:@"Spine" equalTo:spine];
		[spinePrefixQuery orderByAscending:@"turnNumber"];
		NSArray *spinePrefixes = [spinePrefixQuery findObjects];
		
		PFObject *subject = 0;
		NSMutableArray *turns = [[NSMutableArray alloc] init];
		for (int turnNum = 1; turnNum <= numTurns; ++turnNum)
		{
			// Create turn
			PFObject *turn = [PFObject objectWithClassName:@"Turn"];
			[turn setObject:game forKey:@"Game"];
			
			// Set which player is assigned to this turn
			PFUser *turnUser = (turnNum % 2 == 1 ? [PFUser currentUser] : invitee);
			[turn setObject:turnUser forKey:@"User"];
			
			// Set the turn number
			[turn setObject:[NSNumber numberWithInt:turnNum] forKey:@"turnNumber"];
			
			// Retrieve the constraint category for this spine prefix
			NSString *category = [spinePrefixes[turnNum-1] objectForKey:@"Constraint_Category"];
			
			// Add a constraint to the turn
			PFObject *constraint = 0;
			if (turnNum < numTurns)
			{
				// For most turns, get a random constraint matching that constraint category
				PFQuery *constraintQuery = [PFQuery queryWithClassName:@"Constraint"];
				[constraintQuery whereKey:@"Category" equalTo:category];
				results = [constraintQuery findObjects];
				
				// De-dupe
				bool duplicate = false;
				do {
					constraint = results[rand() % results.count];
					duplicate = false;
					for (int i=0; i < turns.count; ++i)
					{
						PFObject *prevConstraint = [((PFObject*)turns[i]) objectForKey:@"Constraint"];
						if ([prevConstraint.objectId isEqualToString:constraint.objectId]) duplicate = true;
					}
				} while (duplicate == true);
				turns[turnNum-1] = turn;
				
				// Store the subject (first constraint)
				if (turnNum == 1) subject = constraint;
			}
			else
			{
				// For final turn, repeat subject
				constraint = subject;
			}
			// Assign constraint to turn
			[turn setObject:constraint forKey:@"Constraint"];
			
			// Persist turn via Parse
			[turn save];
		}
		
		// Send the resulting new game to the PlayViewController
		PlayStoryViewController *controller = (PlayStoryViewController *)segue.destinationViewController;
		controller.game = game;
	}
}

@end
