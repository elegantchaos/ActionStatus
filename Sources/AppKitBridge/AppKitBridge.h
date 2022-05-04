//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Sam Deane on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_CLOSED_ENUM(NSUInteger, ItemStatus) { // NB: order should match the constants in Repo.State
    ItemStatusUnknown,
    ItemStatusSucceeded,
    ItemStatusFailed,
    ItemStatusQueued,
    ItemStatusRunning,
};

/// Protocol implemented by the UIKit side of the bridge.
/// Provides information and callbacks to the AppKit side.
@protocol AppKitBridgeDelegate <NSObject>
- (NSString*)windowToIntercept;
- (NSInteger) itemCount;
- (NSString*) nameForItem: (NSInteger) item;
- (ItemStatus) statusForItem: (NSInteger) item;
- (void) selectItem: (NSInteger) item;
- (void) showPreferences;
- (BOOL) toggleEditing;
- (void) addItem;
@end

/// Protocol implemented by the AppKit side of the bridge.
@protocol AppKitBridge <NSObject>
@property (nonatomic) ItemStatus status;
@property (nonatomic) BOOL showInMenu;
@property (nonatomic) BOOL showInDock;
@property (nonatomic) BOOL showAddButton;
@property (nonatomic, readonly) SEL showWindowSelector;

- (void) setupWithDelegate: (id<AppKitBridgeDelegate>) delegate;
- (id) makeToolbar;
- (void) revealInFinder: (NSURL *) url;
- (void) handleQuit: (id) sender;
@end

@interface AppKitBridgeImp <AppKitBridge>
@end

NS_ASSUME_NONNULL_END
