//
//  Constants.m
//  Improv
//
//  Created by Ed Roman on 2/5/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "Constants.h"

static NSDictionary *_data = 0;

@implementation Constants

+(NSArray *)data {return _data;}

+(void) loadData {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Constants" ofType:@"plist"];
		_data = [[NSDictionary alloc] initWithContentsOfFile:path];
}
@end
