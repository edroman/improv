//
//  PlayStoryViewController.m
//  Improv
//
//  Created by Ed Roman on 1/19/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//
// TODO: Figure out how to have "Done" button in nav bar

#import "PlayStoryViewController.h"

@interface PlayStoryViewController ()
@end

@implementation PlayStoryViewController

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
	
	// Figure out which user is our partner, then display his name
	PFUser *creator = [self.game objectForKey:@"creator"];
	PFUser *invitee = [self.game objectForKey:@"invitee"];
	PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
	UILabel *partnerLabel = (UILabel *)[self.view viewWithTag:104];
	partnerLabel.text = [NSString stringWithFormat:@"Game with %@", [partner objectForKey:@"first_name"]];

	////////////////////////////////////////////
	// BEGIN Compose the existing story so far plus constraints
	////////////////////////////////////////////
	
	NSMutableString *story = [[NSMutableString alloc] init];
	UILabel *storyLabel = (UILabel *)[self.view viewWithTag:101];
	NSString *intro = [[self.game objectForKey:@"intro"] objectForKey:@"value"];
	int playerTurn = [[self.game objectForKey:@"currTurnNumber"] intValue];
	
	// Add the intro to the historical story so far if we've progressed that far...
	if (playerTurn >= 2) [story appendString:intro];

	// Find all turns for this game
	PFQuery *query = [PFQuery queryWithClassName:@"Turn"];
	[query includeKey:@"Constraint"];
	[query whereKey:@"Game" equalTo:self.game];
	[query orderByAscending:@"turnNumber"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *turns, NSError *error) {
		if (!error) {
			NSLog(@"Successfully retrieved %d results.", turns.count);
			
			// For each turn...
			for (int i=0; i < turns.count; ++i) {
				PFObject *turn = turns[i];
				int turnNumber = [[turn objectForKey:@"turnNumber"] intValue];
				
				// If we're on the player's turn number..
				if (turnNumber == playerTurn)
				{
					// Assign to local storage so we can manipulate later
					self.currTurn = turn;

					// Display next story spine or intro in the "player instructions" for this turn
					UILabel *spineLabel = (UILabel *)[self.view viewWithTag:102];
					if (playerTurn >= 2) {
						NSString *str = [NSString stringWithFormat:@"prefix%d", playerTurn-1];
						NSString *prefix = [[self.game objectForKey:@"spine"] objectForKey:str];
						spineLabel.text = [NSString stringWithFormat:@"%@...", prefix];
					}
					else {
						spineLabel.text = intro;
					}
					
					// Display current constraint
					UILabel *constraintLabel = (UILabel *)[self.view viewWithTag:105];
					NSString *constraint = [[turn objectForKey:@"Constraint"] objectForKey:@"phrase"];
					constraintLabel.text = [NSString stringWithFormat:@"You must use the word '%@'!", constraint];
				}
				
				// Otherwise, if we're on a previous turn from the current turn, construct the story so far..
				else if (turnNumber < playerTurn)
				{
					// Add story spine (not for first, since that is the intro)
					if (turnNumber > 1)
					{
						NSString *str = [NSString stringWithFormat:@"prefix%d", turnNumber];
						NSString *spine = [[self.game objectForKey:@"spine"] objectForKey:str];
						[story appendString:spine];
						
						// Add space after spine
						[story appendString:@" "];
					}
					
					// Add turn text
					NSString *turnStr = [turn objectForKey:@"turn"];
					[story appendString:turnStr];
					
					// Add space after turn
					[story appendString:@" "];
				}
			}
			
			// Update label
			storyLabel.text = story;
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
	}];

	////////////////////////////////////////////
	// END Compose the existing story so far
	////////////////////////////////////////////

	// Assign the UITextFieldDelegate
	UITextField *textField = (UITextField *)[self.view viewWithTag:103];
	textField.delegate = self;
	[textField setReturnKeyType:UIReturnKeyDone];
}

// Before the lobby segue is triggered, we validate the content the user submitted
//
// TODO: Use UITextFieldDelegate for this, plus "Done" button
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"PlayStoryToLobbySegue"]) {
		UITextField *content = (UITextField *)[self.view viewWithTag:103];
		if (content.text.length == 0) {
			// TODO: Show error
			return false;
		}
		
		// Validate that constraint was used
		NSString *constraint = [[self.currTurn objectForKey:@"Constraint"] objectForKey:@"phrase"];
		if ([content.text rangeOfString:constraint options:NSCaseInsensitiveSearch].location == NSNotFound)
		{
			NSLog(@"String does NOT contain constraint");
			UIAlertView *alert = [[UIAlertView alloc]
										 initWithTitle:@"Nice try!"
										 message:[NSString stringWithFormat:@"You must use the phrase '%@' somewhere!", constraint]
										 delegate:nil
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
			[alert show];
			return false;
		}
		else
		{
			NSLog(@"String contains constraint!");
			return true;
		}
	}

	return true;
}

// Callback that's invoked when the user presses return/done
-(BOOL)textFieldShouldReturn:(UITextField *)textField {

	// Dismiss the keyboard
	[textField resignFirstResponder];

	return YES;
}

// Called when the player presses "Submit".  Here we should submit the turn to the server.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"PlayStoryToLobbySegue"]) {
		//////////////////////////////////////////////
		// Correct punctuation at end of sentence
		//////////////////////////////////////////////
		
		UITextField *content = (UITextField *)[self.view viewWithTag:103];
		NSMutableString *str = [NSMutableString stringWithString:content.text];
		char c = [str characterAtIndex:([str length]-1)];
		if (c != '.' && c != '!' && c != '?') {
			[str insertString:@"." atIndex:[str length]];
		}
		
		//////////////////////////////////////////////
		// Update our game/turn in Parse
		//////////////////////////////////////////////
		
		// Find the matching turn for this game
		PFQuery *query = [PFQuery queryWithClassName:@"Turn"];
		[query whereKey:@"Game" equalTo:self.game];
		int turnNum = [[self.game objectForKey:@"currTurnNumber"] intValue];
		[query whereKey:@"turnNumber" equalTo:[NSNumber numberWithInt:turnNum]];
		
		// Execute query
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				// The find succeeded.
				if (objects.count != 1) NSLog(@"Error - should have found exactly 1 result!!!");
				else NSLog(@"Successfully retrieved %d results.", objects.count);
				
				////////////////////////////////////
				// Update current turn
				////////////////////////////////////
				
				// Set the value of the turn
				PFObject *turn = objects[0];
				[turn setObject:str forKey:@"turn"];
				
				// Persist via Parse
				[turn save];
				
				////////////////////////////////////
				// Update main game object
				// (necessary in here since turnNum could be updated prior to previous query finishing)
				////////////////////////////////////
				
				// Increase turn number
				int turnNum = [[self.game objectForKey:@"currTurnNumber"] intValue];
				turnNum = turnNum + 1;
				[self.game setObject:[NSNumber numberWithInt:turnNum] forKey:@"currTurnNumber"];
				
				// Set completed flag
				if (turnNum > [[[Constants data] objectForKey:@"numTurns"] intValue])
				{
					[self.game setObject:[NSNumber numberWithBool:true] forKey:@"completed"];
				}
				
				// Flip the current player
				PFUser *creator = [self.game objectForKey:@"creator"];
				PFUser *invitee = [self.game objectForKey:@"invitee"];
				PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
				[self.game setObject:partner forKey:@"currPlayer"];
				
				// Persist game via Parse
				[self.game save];
				
				////////////////////////////////////
				// Send Push Notification to partner
				////////////////////////////////////
				
				// Find devices (called "installations" in parse) associated with our partner
				PFQuery *userQuery = [PFUser query];
				[userQuery whereKey:@"objectId" equalTo:partner.objectId];
				PFQuery *pushQuery = [PFInstallation query];
				[pushQuery whereKey:@"owner" matchesQuery:userQuery];
				
				// Send push notification to query
				PFPush *push = [[PFPush alloc] init];
				[push setQuery:pushQuery]; // Set our Installation query
				[push setMessage:[NSString stringWithFormat:@"Hi %@!  %@ just completed their turn in A Tall Tale and is waiting on you.  It's now your turn!",
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
				
			} else {
				// Log details of the failure
				NSLog(@"Error: %@ %@", error, [error userInfo]);
			}
		}];
		
		// Segue will automatically go to lobby.
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
