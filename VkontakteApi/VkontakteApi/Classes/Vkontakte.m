//
//  Vkontakte.m
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/23/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import "Vkontakte.h"
#import "VkontakteLoginViewController.h"
#import "VkontakteConstants.h"
#import "VKRequest.h"

@interface Vkontakte()



@end

@implementation Vkontakte

@synthesize clientId=_clientId, scope=_scope, delegate=_delegate;

@dynamic userID, accessToken, accessTokenDate;

- (VKRequest *)requestWithMethod:(NSString *)methodName andParams:(NSDictionary *)params andDelegate:(id <VKRequestDelegate>)delegate
{
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@", kVKServerAddressMethod, methodName];
    VKRequest *request = [[VKRequest alloc] init];
    request.delegate = delegate;
    request.url = fullUrl;
    request.httpMethod = @"GET";
    
    NSMutableDictionary *fullParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if ([self isSessionValid]) {
        [fullParams setValue:[self.accessToken stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                  forKey:@"access_token"];
    }
    
    request.params = fullParams;
    return [request autorelease];
}

- (VKRequest *)requestWithMethod:(NSString *)methodName andDelegate:(id <VKRequestDelegate>)delegate
{
    return [self requestWithMethod:methodName andParams:[NSDictionary dictionary] andDelegate:delegate];
}

- (id)initWithClientId:(NSString *)clientId
{
    self = [super init];
    if (self) {
        self.clientId = clientId;
    }
    return self;
}

- (void)authorize:(NSString *)scope withDelegate:(id <VkontakteSessionDelegate>)delegate
{
    if(!_clientId) {
        NSAssert(@"assert", @"%@", @"clientId connot be nil.");
    }
    
    self.scope = scope;
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    if (window && window.rootViewController) {
        VkontakteLoginViewController *vkontakteLoginViewController = [[VkontakteLoginViewController alloc] initWithNibName:@"VkontakteLoginViewController" bundle:nil];
        
        vkontakteLoginViewController.scope = self.scope;
        vkontakteLoginViewController.clientId = self.clientId;
        vkontakteLoginViewController.vkontakte = self;
        
        [window.rootViewController presentModalViewController:vkontakteLoginViewController animated:YES];
        [vkontakteLoginViewController release];
    }
}

- (void)logoutWithDelegate:(id <VkontakteSessionDelegate>)delegate
{
    self.delegate = delegate;
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kVKUserIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kVKAccesToken];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kVKAccesTokenDate];
    
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *vkontakteCookies = [cookies cookiesForURL: [NSURL URLWithString:@"http://login.vk.com"]];
    
    for (NSHTTPCookie* cookie in vkontakteCookies) {
        [cookies deleteCookie:cookie];
    }
    
    if ([_delegate respondsToSelector:@selector(didLogout:)]) {
        [_delegate didLogout:self];
    }
}

- (BOOL)isSessionValid 
{
    return (self.accessToken != nil && self.accessTokenDate != nil
            && NSOrderedDescending == [self.accessTokenDate compare:[NSDate date]]);
}

- (NSString *)userID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kVKUserIDKey];
}

- (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccesToken];
}

- (NSDate *)accessTokenDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccesTokenDate];
}

- (void)dealloc
{
    self.delegate = nil;
    self.scope = nil;
    self.clientId = nil;
    [super dealloc];
}

@end
