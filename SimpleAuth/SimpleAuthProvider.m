//
//  SimpleAuthProvider.m
//  SimpleAuth
//
//  Created by Caleb Davenport on 11/6/13.
//  Copyright (c) 2013-2014 Byliner, Inc. All rights reserved.
//

#import "SimpleAuthProvider.h"
#import "SimpleAuthActivityIndicator.h"

#import "NSObject+SimpleAuthAdditions.h"

@interface SimpleAuthProvider ()

@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic, readonly) SimpleAuthActivityIndicator *activityIndicator;

@end

@implementation SimpleAuthProvider {
    NSInteger _activityCount;
}

@synthesize operationQueue = _operationQueue;
@synthesize activityIndicator = _activityIndicator;

#pragma mark - Public

+ (NSString *)type {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


+ (NSDictionary *)defaultOptions {
    return @{};
}


- (instancetype)initWithOptions:(NSDictionary *)options {
    if ((self = [super init])) {
        self.options = options;
    }
    return self;
}


- (void)authorizeWithCompletion:(SimpleAuthRequestHandler)completion {
    [self doesNotRecognizeSelector:_cmd];
}


- (void)beginActivity {
    dispatch_async(dispatch_get_main_queue(), ^{
        _activityCount++;
        if (_activityCount == 1) {
            [self.activityIndicator showActivityIndicator];
        }
    });
}


- (void)endActivity {
    dispatch_async(dispatch_get_main_queue(), ^{
        _activityCount = MAX(_activityCount - 1, 0);
        if (_activityCount == 0) {
            [self.activityIndicator hideActivityIndicator];
        }
    });
}


#pragma mark - Accessors

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}


- (SimpleAuthActivityIndicator *)activityIndicator {
    if (!_activityIndicator) {
        Class klass = [[self class] activityIndicatorClass];
        if (klass == Nil) {
            return nil;
        }
        _activityIndicator = [klass new];
    }
    return _activityIndicator;
}


#pragma mark - Private

+ (Class)activityIndicatorClass {
    static dispatch_once_t token;
    static Class klassOne;
    dispatch_once(&token, ^{
        [SimpleAuthActivityIndicator SimpleAuth_enumerateSubclassesWithBlock:^(Class klassTwo, BOOL *stop) {
            klassOne = klassTwo;
            *stop = YES;
        }];
    });
    return klassOne;
}

@end
