//
//  RNPUserSession.m
//  Foodie
//
//  Created by Romi Phadte on 3/26/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPUserSession.h"
#import <FacebookSDK/Facebook.h>

@interface RNPUserSession ()


@end


@implementation RNPUserSession

RNPUserSession *_sharedInstance;


-(RNPUserSession*) init{
    
    self = [super init];
    if (self) {
        self.isLoggedIn=FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded;
    }
    return self;
    
}

+(RNPUserSession *)sharedInstance{
    if(_sharedInstance==nil){
        _sharedInstance=[[RNPUserSession alloc] init];
    }
    
    return _sharedInstance;
    
}

-(BOOL)loginWith:(id<FBGraphUser>)FB{
    self.FBuser=FB;
    return [self login];
}


-(BOOL)login{
    self.isLoggedIn=YES;
    return self.isLoggedIn;
}

-(BOOL)logOut{
    self.isLoggedIn=NO;
    self.FBuser=nil;
    [FBSession.activeSession closeAndClearTokenInformation];
    return !self.isLoggedIn;
}

-(NSString *)UniqueID{
    return self.FBuser.id;   //TODO: implementation may change from FB ID

}




@end
