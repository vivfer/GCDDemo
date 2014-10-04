//
//  AppDelegate.m
//  GCDDemo
//
//  Created by jianleer on 14-10-4.
//  Copyright (c) 2014年 jianleer. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //-----------------------------分割线-----------------------------
    //GCD的定义
    //声明变量
    void (^jianleerBlock)(void);
    //定义
    jianleerBlock = ^{
        NSLog(@"Hello world");
    };
    //调用
    jianleerBlock();
    
    //block有如下特点：
    //1.	程序块可以在代码中以内联的方式来定义。
    //2.	程序块可以访问在创建它的范围内的可用的变量。
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //somthing
    });
    
    
    //-----------------------------分割线-----------------------------

    //系统提供的dispatch方法
    //后台执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //somthing
        NSLog(@"后台执行");
    });
    //主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        NSLog(@"主线程执行");
    });
    
    //一次性执行
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        NSLog(@"一次性执行");
    });
    
    //延迟两秒执行
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        //代码将在5秒后在主线程里执行
        NSLog(@"延迟5秒执行");
    });
    
    //-----------------------------分割线-----------------------------

    
    //自定义dispatch
    dispatch_queue_t urls_queue = dispatch_queue_create("baidu.com", nil);
    dispatch_async(urls_queue, ^{
       //代码
    });
    dispatch_release(urls_queue);
    
    
    __block int a= 0,b = 0;
    //GCD高级用法
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //并行执行线程1
         a = 5;
        NSLog(@"并行执行线程1");
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //并行执行线程2
        b = 10;
        NSLog(@"并行执行线程1");
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        //汇总结果
        int c = a + b;
        NSLog(@"汇总结果 : %d",c);
    });
    
    //-----------------------------分割线-----------------------------
//修改block之外的变量
    
    __block int m = 0;
    void (^chang)(void) = ^{
        m = 100;
        NSLog(@"更改后的值 : %d",m);
    };
    chang();
    
    //-----------------------------分割线-----------------------------

    
    
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"按home键调用此方法");
    
    //GCD后台运行
    
    [self bgTaskRun];
    //此处添加需长久运行的代码
    
    if (1) {
        for (int i = 0; i < 10; i++) {
            NSLog(@"i : %d",i);
        }
    }
    
    
    [self endBgTaskRun];
    
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


-(void)bgTaskRun{
    NSLog(@"后台任务开始");
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBgTaskRun];
    }];
}
-(void)endBgTaskRun{
    NSLog(@"后台任务完成");
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jianleer.demo.GCDDemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GCDDemo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GCDDemo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
