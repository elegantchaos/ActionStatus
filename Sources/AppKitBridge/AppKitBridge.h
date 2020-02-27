//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Developer on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ItemStatus) {
    ItemStatusUnknown,
    ItemStatusFailed,
    ItemStatusSucceeded,
};

@protocol SparkleDriver <NSObject>
- (void)showCanCheckForUpdates:(BOOL)canCheckForUpdates;
- (void)showUpdatePermissionRequest:(NSArray<NSDictionary<NSString *, NSString *> *> *)request reply:(void (^)(NSDictionary<NSString *, NSNumber *> *))reply;
- (void)showUserInitiatedUpdateCheckWithCompletion:(void (^)(NSUInteger))updateCheckStatusCompletion;
- (void)dismissUserInitiatedUpdateCheck;
- (void)showUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSInteger))reply;
- (void)showDownloadedUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSInteger))reply;
- (void)showResumableUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSUInteger))reply;
- (void)showInformationalUpdateFoundWithAppcastItem:(NSDictionary *)appcastItem userInitiated:(BOOL)userInitiated reply:(void (^)(NSInteger))reply;
- (void)showUpdateReleaseNotesWithDownloadData:(NSDictionary *)downloadData;
- (void)showUpdateReleaseNotesFailedToDownloadWithError:(NSError *)error;
- (void)showUpdateNotFoundWithAcknowledgement:(void (^)(void))acknowledgement;
- (void)showUpdaterError:(NSError *)error acknowledgement:(void (^)(void))acknowledgement;
- (void)showDownloadInitiatedWithCompletion:(void (^)(NSUInteger))downloadUpdateStatusCompletion;
- (void)showDownloadDidReceiveExpectedContentLength:(uint64_t)expectedContentLength;
- (void)showDownloadDidReceiveDataOfLength:(uint64_t)length;
- (void)showDownloadDidStartExtractingUpdate;
- (void)showExtractionReceivedProgress:(double)progress;
- (void)showReadyToInstallAndRelaunch:(void (^)(NSUInteger))installUpdateHandler;
- (void)showInstallingUpdate;
- (void)showSendingTerminationSignal;
- (void)showUpdateInstallationDidFinishWithAcknowledgement:(void (^)(void))acknowledgement;
- (void)dismissUpdateInstallation;
@end

@protocol MenuDataSource <NSObject>
- (NSInteger) itemCount;
- (nonnull NSString*) nameForItem: (NSInteger) item;
- (ItemStatus) statusForItem: (NSInteger) item;
- (void) selectItem: (NSInteger) item;
@end

@protocol AppKitBridge <NSObject>
@property BOOL passing;
@property BOOL showInMenu;
@property BOOL showInDock;

- (void) setupWithSparkleDriver: (nonnull id<SparkleDriver>)sparkleDriver capturingWindowNamed: (nonnull NSString*) windowName dataSource: (nonnull id<MenuDataSource>) source;
- (nonnull SEL) showHandler;
@end

@interface AppKitBridgeImp <AppKitBridge>
@end

NS_ASSUME_NONNULL_END
