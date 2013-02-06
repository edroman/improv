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
				
				// Add story spine + turn
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

	// Display next story spine (if we're beyond the intro)
	UILabel *spineLabel = (UILabel *)[self.view viewWithTag:102];
	if (turn >= 2) {
		NSString *str = [NSString stringWithFormat:@"prefix%d", turn-1];
		NSString *prefix = [[self.game objectForKey:@"spine"] objectForKey:str];
		spineLabel.text = [NSString stringWithFormat:@"%@...", prefix];
	}
	else {
		spineLabel.text = intro;
	}
	
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
		// Create the new turn in Parse
		//////////////////////////////////////////////

		PFObject *turn = [PFObject objectWithClassName:@"Turn"];
		[turn setObject:self.game forKey:@"Game"];
		[turn setObject:[PFUser currentUser] forKey:@"User"];
		
		int turnNum = [[self.game objectForKey:@"turn"] intValue];
		[turn setObject:[NSNumber numberWithInt:turnNum] forKey:@"turnNumber"];

		[turn setObject:str forKey:@"turn"];

		// Persist via Parse
		[turn save];
		
		////////////////////////////////////
		// Update main game object
		////////////////////////////////////

		// Increase turn number
		turnNum = turnNum + 1;
		[self.game setObject:[NSNumber numberWithInt:turnNum] forKey:@"turn"];
		
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
		
		// Persist via Parse
		[self.game save];

		// Segue will automatically go to lobby.
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
