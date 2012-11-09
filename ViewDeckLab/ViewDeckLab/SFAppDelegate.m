//
//  SFAppDelegate.m
//  ViewDeckLab
//
//  Created by Plato on 11/5/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import "SFAppDelegate.h"
#import "IIViewDeckController.h"
#import "SFMainViewController.h"

@implementation SFAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    //center view controller
    SFMainViewController * tableController = [[[SFMainViewController alloc]init] autorelease];
    UINavigationController * centerViewController = [[[UINavigationController alloc]initWithRootViewController:tableController] autorelease];
    
    //left view controller
    UIViewController * leftViewController = [[[UIViewController alloc]init] autorelease];
    leftViewController.view.backgroundColor = [UIColor redColor];
    
    //right view controller
    UIViewController * rightViewController = [[[UIViewController alloc]init] autorelease];
    rightViewController.view.backgroundColor = [UIColor blueColor];
    
    IIViewDeckController * deckController =
    [[IIViewDeckController alloc]initWithCenterViewController:centerViewController
                                           leftViewController:leftViewController
                                          rightViewController:rightViewController];
    deckController.leftLedge = 320;
    deckController.rightLedge = 480;
    
    self.window.rootViewController = deckController;
    [deckController release];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
