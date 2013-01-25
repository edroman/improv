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

	// TODO: Modify this based on parse data
	UILabel *partnerLabel = (UILabel *)[self.view viewWithTag:104];
	partnerLabel.text = @"Game with Harvey Dent";

	// TODO: Based on the model, populate the turn & story so far
	int turn = 1;
	UILabel *storyLabel = (UILabel *)[self.view viewWithTag:101];
	storyLabel.text = @"Once upon a time, we were walking through the forest...";

	UILabel *spineLabel = (UILabel *)[self.view viewWithTag:102];

	// TODO: Have story spines be driven from Parse
	switch (turn)
	{
		case 1:
			spineLabel.text = @"And every day...";
			break;
		case 2:
			spineLabel.text = @"Until one day...";
			break;
		case 3:
			spineLabel.text = @"And because of that...";
			break;
		case 4:
			spineLabel.text = @"And because of that...";
			break;
		case 5:
			spineLabel.text = @"And because of that...";
			break;
		case 6:
			spineLabel.text = @"Until finally...";
			break;
		case 7:
			spineLabel.text = @"And ever since that day...";
			break;
		case 8:
			spineLabel.text = @"The moral of the story is...";
			break;
	}
	
	// Assign the UITextFieldDelegate
	UITextField *textField = (UITextField *)[self.view viewWithTag:103];
	textField.delegate = self;
	[textField setReturnKeyType:UIReturnKeyDone];

	// For keyboard scrolling:
	// Assign UIScrollView delegate

	((UIScrollView*) self.view).delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector (keyboardDidShow:)
																name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector (keyboardDidHide:)
																name: UIKeyboardDidHideNotification object:nil];
}

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
	}

	return true;
}

// Creates a "Done" button for text editing
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
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
