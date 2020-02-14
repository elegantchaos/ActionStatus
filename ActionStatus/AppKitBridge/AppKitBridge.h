//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Developer on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol AppKitBridge <NSObject>
@property BOOL passing;
- (void) setup;
@end
