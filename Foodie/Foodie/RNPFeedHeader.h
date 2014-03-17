//
//  RNPFeedHeader.h
//  Foodie
//
//  Created by Neeraj Baid on 3/2/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXBlurView/FXBlurView.h>
#import <OHAttributedLabel/OHAttributedLabel.h>

@protocol RNPHeaderTouchDelegate <NSObject>

- (void)touchedRestaurant:(NSString *)restaurantName withID:(NSString *)restaurantID;
- (void)touchedUser:(NSString *)username;

@end

@interface RNPFeedHeader : UIView

@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet OHAttributedLabel *label;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *likes;
@property (strong, nonatomic) NSString *restaurantName;
@property (strong, nonatomic) NSString *restaurantID;
@property (strong, nonatomic) id <RNPHeaderTouchDelegate> delegate;

@end
