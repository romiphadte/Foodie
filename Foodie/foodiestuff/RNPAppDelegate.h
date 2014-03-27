//
//  RNPAppDelegate.h
//  foodiestuff
//
//  Created by Romi Phadte on 3/25/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
