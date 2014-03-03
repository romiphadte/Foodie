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

@interface RNPFeedHeader : UIView

@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet OHAttributedLabel *label;

@end
