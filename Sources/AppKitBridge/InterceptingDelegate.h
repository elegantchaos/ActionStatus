//
//  AppKitBridge.h
//  ActionStatus
//
//  Created by Sam Deane on 14/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface InterceptingDelegate: NSProxy
- (nonnull id)initWithWindow: (nonnull id) windowIn interceptor: (nonnull id) bridgeIn;
@end
