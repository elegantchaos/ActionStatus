//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Developer on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ItemStatus) {
    ItemStatusUnknown,
    ItemStatusFailed,
    ItemStatusSucceeded,
};

@protocol MenuDataSource <NSObject>
- (NSInteger) itemCount;
- (nonnull NSString*) nameForItem: (NSInteger) item;
- (ItemStatus) statusForItem: (NSInteger) item;
- (void) selectItem: (NSInteger) item;
@end

@protocol AppKitBridge <NSObject>
@property BOOL passing;
- (void) setup;
- (void) didSetup: (nonnull id) window;
- (void) setDataSource: (nonnull id<MenuDataSource>) source;
- (nonnull SEL) showHandler;
@end

@interface AppKitBridgeImp <AppKitBridge>
@end
