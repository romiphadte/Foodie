//
//  RNPFeedViewController.h
//  Foodie
//
//  Created by Neeraj Baid on 3/2/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RNPFeedNavigationItemView.h"
#import "RNPFeedHeader.h"

@interface RNPFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, RNPFeedNavigationItemViewDelegate, RNPHeaderTouchDelegate>

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSDictionary *profilePictures;

@property (strong, nonatomic) CLLocation *currentLocation;

@end
