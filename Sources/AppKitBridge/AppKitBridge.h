//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Sam Deane on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_CLOSED_ENUM(NSUInteger, ItemStatus) {
    ItemStatusUnknown,
    ItemStatusFailed,
    ItemStatusSucceeded,
};

@protocol MenuDataSource <NSObject>
- (NSInteger) itemCount;
- (NSString*) nameForItem: (NSInteger) item;
- (ItemStatus) statusForItem: (NSInteger) item;
- (void) selectItem: (NSInteger) item;
- (void) checkForUpdates;
- (BOOL) toggleEditing;
- (void) addItem;
@end

@protocol AppKitBridge <NSObject>
@property (nonatomic)BOOL passing;
@property (nonatomic)BOOL showInMenu;
@property (nonatomic) BOOL showInDock;
@property (nonatomic) BOOL showAddButton;
@property (nonatomic) BOOL showUpdates;
@property (nonatomic, readonly) SEL showWindowSelector;

- (void) setupCapturingWindowNamed: (NSString*) windowName dataSource: (id<MenuDataSource>) source;
- (id) makeToolbar;
@end

@interface AppKitBridgeImp <AppKitBridge>
@end

NS_ASSUME_NONNULL_END
