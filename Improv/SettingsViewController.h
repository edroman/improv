//
//  SettingsViewController.h
//  Improv
//
//  Created by Ed Roman on 2/3/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)FeedbackAction:(id)sender;

@end
