//
//  RNPFeedNavigationItemView.h
//  Foodie
//
//  Created by Neeraj Baid on 3/13/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RNPFeedNavigationItemViewDelegate <NSObject>

- (void)setFeedSelection:(NSInteger)selectedIndex;

@end

@interface RNPFeedNavigationItemView : UIView

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) id <RNPFeedNavigationItemViewDelegate> delegate;

- (void)setSelectedIndex:(NSInteger)selectedIndex;

@end
