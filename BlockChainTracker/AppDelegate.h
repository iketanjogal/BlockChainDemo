//
//  AppDelegate.h
//  BlockChainTracker
//
//  Created by jogi on 02/07/18.
//  Copyright © 2018 ketanDemo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

