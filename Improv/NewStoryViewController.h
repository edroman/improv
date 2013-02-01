//
//  NewStoryViewController.h
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>

@interface NewStoryViewController : UIViewController <PF_FBFriendPickerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
- (IBAction)showFBFriendPicker;

- (IBAction)showAddressBookPicker;

@end