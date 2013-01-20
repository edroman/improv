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
