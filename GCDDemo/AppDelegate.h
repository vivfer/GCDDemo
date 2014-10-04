//
//  AppDelegate.h
//  GCDDemo
//
//  Created by jianleer on 14-10-4.
//  Copyright (c) 2014年 jianleer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    
}

//GCD后台运行
@property(assign ,nonatomic)UIBackgroundTaskIdentifier bgTask;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

