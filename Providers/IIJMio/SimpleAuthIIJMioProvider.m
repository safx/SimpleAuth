//
//  SimpleAuthIIJMioProvider.m
//  MioDashboard
//
//  Created by Safx Developer on 2014/01/29.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

#import "SimpleAuthIIJMioProvider.h"
#import "SimpleAuthIIJMioLoginViewController.h"

#import "UIViewController+SimpleAuthAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


@implementation SimpleAuthIIJMioProvider

#pragma mark - SimpleAuthProvider

+ (NSString *)type {
    return @"iijmio";
}

+ (NSDictionary *)defaultOptions {
    
    // Default present block
    SimpleAuthInterfaceHandler presentBlock = ^(UIViewController *controller) {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        UIViewController *presented = [UIViewController SimpleAuth_presentedViewController];
        [presented presentViewController:navigation animated:YES completion:nil];
    };
    
    // Default dismiss block
    SimpleAuthInterfaceHandler dismissBlock = ^(id controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[super defaultOptions]];
    options[SimpleAuthPresentInterfaceBlockKey] = presentBlock;
    options[SimpleAuthDismissInterfaceBlockKey] = dismissBlock;
    return options;
}


- (void)authorizeWithCompletion:(SimpleAuthRequestHandler)completion {
    [[[self accessToken]
      flattenMap:^RACStream *(NSString *response) {
          NSArray *signals = @[[RACSignal return:response]];
          return [self rac_liftSelector:@selector(dictionaryWithAccessToken:) withSignalsFromArray:signals];
      }]
     subscribeNext:^(NSDictionary *response) {
         completion(response, nil);
     }
     error:^(NSError *error) {
         completion(nil, error);
     }];
}


#pragma mark - Private

- (RACSignal *)accessToken {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SimpleAuthIIJMioLoginViewController *login = [[SimpleAuthIIJMioLoginViewController alloc] initWithOptions:self.options];
            login.completion = ^(UIViewController *login, NSURL *URL, NSError *error) {
                SimpleAuthInterfaceHandler dismissBlock = self.options[SimpleAuthDismissInterfaceBlockKey];
                dismissBlock(login);
                
                // Parse URL
                NSString *fragment = [URL fragment];
                NSDictionary *dictionary = [CMDQueryStringSerialization dictionaryWithQueryString:fragment];
                NSString *token = dictionary[@"access_token"];
                
                // Check for error
                if (![token length]) {
                    [subscriber sendError:error];
                    return;
                }
                
                // Send completion
                [subscriber sendNext:token];
                [subscriber sendCompleted];
            };
            
            SimpleAuthInterfaceHandler block = self.options[SimpleAuthPresentInterfaceBlockKey];
            block(login);
        });
        return nil;
    }];
}

#pragma mark - Private

- (NSDictionary *)dictionaryWithAccessToken:(NSString *)accessToken {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    // Provider
    dictionary[@"provider"] = [[self class] type];
    
    // Credentials
    dictionary[@"credentials"] = @{@"token" : accessToken};
    
    return dictionary;
}

@end
