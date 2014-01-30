//
//  SimpleAuthIIJMioLoginWebViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2014/01/29.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

#import "SimpleAuthIIJMioLoginViewController.h"

@implementation SimpleAuthIIJMioLoginViewController

#pragma mark - SimpleAuthWebViewController

- (instancetype)initWithOptions:(NSDictionary *)options requestToken:(NSDictionary *)requestToken {
    if ((self = [super initWithOptions:options requestToken:requestToken])) {
        self.title = @"IIJMio";
    }
    return self;
}


- (NSURLRequest *)initialRequest {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"client_id"] = self.options[@"client_id"];
    parameters[@"redirect_uri"] = self.options[SimpleAuthRedirectURIKey];
    parameters[@"response_type"] = @"token";
    if (self.options[@"state"]) {
        parameters[@"state"] = self.options[@"state"];
    }
    NSString *URLString = [NSString stringWithFormat:
                           @"https://api.iijmio.jp/mobile/d/v1/authorization/?%@",
                           [CMDQueryStringSerialization queryStringWithDictionary:parameters]];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    return [NSURLRequest requestWithURL:URL];
}

@end
