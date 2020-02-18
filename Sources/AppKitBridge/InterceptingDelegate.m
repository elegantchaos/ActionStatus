//
//  AppKitBridge.m
//  AppKitBridge
//
//  Created by Developer on 18/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

#import "InterceptingDelegate.h"
#import "AppKitBridge.h"

@import AppKit;

@interface InterceptingDelegate() <NSWindowDelegate>
@property NSObject<NSWindowDelegate>* original;
@property NSObject<NSWindowDelegate>* replacement;
@end

@implementation InterceptingDelegate

- (nonnull id)initWithWindow: (nonnull id) window interceptor: (nonnull id) replacement {
    _original = [window delegate];
    _replacement = replacement;
    [window setDelegate: self];
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_original methodSignatureForSelector: sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    id target = (invocation.selector == @selector(windowShouldClose:)) ? _replacement : _original;
    [invocation invokeWithTarget:target];
}

@end
