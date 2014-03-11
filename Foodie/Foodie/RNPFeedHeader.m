//
//  RNPFeedHeader.m
//  Foodie
//
//  Created by Neeraj Baid on 3/2/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPFeedHeader.h"

@implementation RNPFeedHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began");
    CGPoint touch = [[touches anyObject] locationInView:self];
//    NSLog(@"label bounds: %@", NSStringFromCGRect([_label bounds]));
//    NSLog(@"username bounds: %@", NSStringFromCGRect([_username bounds]));
//    NSLog(@"profile picture bounds: %@", NSStringFromCGRect([_profilePicture bounds]));
//    NSLog(@"touch location: %@", NSStringFromCGPoint([touch locationInView:self]));
    CGRect profilePicture = CGRectMake(6, 6, 38, 38);
    CGRect label = CGRectMake(60, 23, 309, 27);
    CGRect username = CGRectMake(50, 5, 239, 20);
    CGRect likes = CGRectMake(289, 0, 30, 21);
    if (CGRectContainsPoint(profilePicture, touch) || CGRectContainsPoint(username, touch))
        NSLog(@"touched username");
    else if (CGRectContainsPoint(likes, touch))
        NSLog(@"touched likes");
    else if (CGRectContainsPoint(label, touch))
        NSLog(@"touched restaurant");
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
