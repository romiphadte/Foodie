//
//  RNPRestaurantFeedViewController.h
//  
//
//  Created by Neeraj Baid on 3/16/14.
//
//

#import "RNPFeedViewController.h"

@interface RNPRestaurantFeedViewController : RNPFeedViewController

@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSString *restaurantID;

- (id)initWithRestaurant:(NSString *)restaurantName withID:(NSString *)restaurantID;

@end
