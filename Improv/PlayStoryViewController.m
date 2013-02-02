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

#define SCROLLVIEW_HEIGHT 460
#define SCROLLVIEW_WIDTH  320

#define SCROLLVIEW_CONTENT_HEIGHT 720
#define SCROLLVIEW_CONTENT_WIDTH  320

BOOL           keyboardVisible;
CGPoint        offset;
UIScrollView  *scrollview;


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
	PFUser *partner = ([PFUser currentUser].objectId == creator.objectId) ? invitee : creator;
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
					}
					
					// Add turn
					NSString *turn = [objects[i] objectForKey:@"turn"];
					[story appendString:turn];
				}
			} else {
				// Log details of the failure
				NSLog(@"Error: %@ %@", error, [error userInfo]);
			}
		}];
		
		storyLabel.text = story;
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

	// For keyboard scrolling:
	// Assign UIScrollView delegate

	scrollview = (UIScrollView*) self.view;
	((UIScrollView*) self.view).delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector (keyboardDidShow:)
																name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector (keyboardDidHide:)
																name: UIKeyboardDidHideNotification object:nil];
}

// Callback that's invoked when the keyboard is displayed.  This is our chance to move widgets around
// so the keyboard doesn't occlude the widgets.
-(void) keyboardDidShow: (NSNotification *)notif
{
	// If keyboard is visible, return
	if (keyboardVisible)
	{
		NSLog(@"Keyboard is already visible. Ignoring notification.");
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	// Save the current location so we can restore
	// when keyboard is dismissed
	offset = scrollview.contentOffset;
	
	// Resize the scroll view to make room for the keyboard
	CGRect viewFrame = scrollview.frame;
	viewFrame.size.height -= keyboardSize.height;
	scrollview.frame = viewFrame;
	
	// Keyboard is now visible
	keyboardVisible = YES;
}

-(void) keyboardDidHide: (NSNotification *)notif
{
	// Is the keyboard already shown
	if (!keyboardVisible)
	{
		NSLog(@"Keyboard is already hidden. Ignoring notification.");
		return;
	}
	
	// Reset the height of the scroll view to its original value
	scrollview.frame = CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT);
	
	// Reset the scrollview to previous location
	scrollview.contentOffset = offset;
	
	// Keyboard is no longer visible
	keyboardVisible = NO;
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
		
		// Create the new turn in Parse
		int turnNum = [[self.game objectForKey:@"turn"] intValue];
		PFObject *turn = [PFObject objectWithClassName:@"Turn"];
		[turn setObject:self.game forKey:@"Game"];
		[turn setObject:[PFUser currentUser] forKey:@"User"];
		[turn setObject:[NSNumber numberWithInt:turnNum] forKey:@"turnNumber"];
		[turn setObject:content.text forKey:@"turn"];
		[turn save];
	}

	return true;
}

// Callback that's invoked when the user presses return/done
-(BOOL)textFieldShouldReturn:(UITextField *)textField {

	// Dismiss the keyboard
	[textField resignFirstResponder];

	return YES;
}

// Validates text field
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	if (textField.text.length == 0) {
		return NO;
	}

	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"PlayStoryToLobbySegue"]) {
		// TODO: Push data via parse.
		// Segue will automatically go to lobby.
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
