//
//  RNPUserSession.h
//  Foodie
//
//  Created by Romi Phadte on 3/26/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/Facebook.h>

@interface RNPUserSession : NSObject

@property id<FBGraphUser> FBuser;


@property BOOL isLoggedIn;

+(RNPUserSession*)sharedInstance;
-(BOOL)loginWith:(id<FBGraphUser>)FB;
-(BOOL)logOut;


@end
