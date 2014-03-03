//
//  RNPFeedCell.m
//  Foodie
//
//  Created by Neeraj Baid on 3/2/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPFeedCell.h"

@implementation RNPFeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width,
                                        self.contentView.frame.size.height);
}

@end
