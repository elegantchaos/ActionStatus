//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Sam Deane on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* ItemStatus NS_TYPED_ENUM;

ItemStatus const ItemStatusUnknown = @"StatusUnknown";
ItemStatus const ItemStatusFailed = @"StatusFailing";
ItemStatus const ItemStatusSucceeded = @"StatusPassing";

@protocol MenuDataSource <NSObject>
- (NSInteger) itemCount;
- (NSString*) nameForItem: (NSInteger) item;
- (ItemStatus) statusForItem: (NSInteger) item;
- (void) selectItem: (NSInteger) item;
- (void) checkForUpdates;
@end

@protocol AppKitBridge <NSObject>
@property (nonatomic)BOOL passing;
@property (nonatomic)BOOL showInMenu;
@property (nonatomic) BOOL showInDock;
@property (nonatomic, readonly) SEL showWindowSelector;

- (void) setupCapturingWindowNamed: (NSString*) windowName dataSource: (id<MenuDataSource>) source;
@end

@interface AppKitBridgeImp <AppKitBridge>
@end

NS_ASSUME_NONNULL_END
