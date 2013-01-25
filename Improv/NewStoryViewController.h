//
//  NewStoryViewController.h
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface NewStoryViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

- (IBAction)showAddressBookPicker;

@end
