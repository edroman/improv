//
//  SettingsViewController.m
//  Improv
//
//  Created by Ed Roman on 2/3/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"SettingsToLoginSegue"]) {
		[PFUser logOut];
	}
}

- (IBAction)FeedbackAction:(id)sender {
	[self sendEmailToRecipient:@"feedback@atalltale.com" subject:@"A Tall Tale feedback" body:@""];
}

- (void)sendEmailToRecipient:(NSString*)recipient subject:(NSString*)subject body:(NSString*)body
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
		[controller setSubject:subject];
		[controller setMessageBody:body isHTML:NO];
		//		[self presentViewController:controller animated:YES completion:NULL];
		[self presentModalViewController:controller animated:YES];
	}
	else
	{
		// TODO: Some sort of error telling user they can't send email
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Failed");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Send");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Saved");
			break;
		default:
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
