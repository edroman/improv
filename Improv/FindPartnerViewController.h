//
//  FindPartnerViewController.h
//  Improv
//
//  Created by Ed Roman on 3/8/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FindPartnerViewController : UIViewController
- (IBAction)searchButtonPressed:(id)sender;
- (IBAction)randomButtonPressed:(id)sender;
@property (nonatomic) PFObject *game;
@end
