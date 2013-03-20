//
//  InviteFriendsViewController.h
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InviteFriendsViewController : UIViewController <PF_FBFriendPickerDelegate, PF_FBDialogDelegate, ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) PFObject *game;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
- (IBAction)showFBFriendPicker;

- (IBAction)showAddressBookPicker;
- (IBAction)continueButtonPressed:(id)sender;

@end
