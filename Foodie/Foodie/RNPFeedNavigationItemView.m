//
//  RNPFeedNavigationItemView.m
//  Foodie
//
//  Created by Neeraj Baid on 3/13/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPFeedNavigationItemView.h"

@implementation RNPFeedNavigationItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self.segmentedControl setSelectedSegmentIndex:selectedIndex];
    [self.delegate setFeedSelection:selectedIndex];
}

- (IBAction)selectedIndexChanged:(id)sender
{
    [self setSelectedIndex:[sender selectedSegmentIndex]];
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
