//
//  Vkontakte.h
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/23/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VKRequest;

@protocol VkontakteSessionDelegate, VKRequestDelegate;

@interface Vkontakte : NSObject

@property(nonatomic, copy) NSString *clientId;
@property(nonatomic, copy) NSString *scope;
@property(nonatomic, assign) id <VkontakteSessionDelegate> delegate;

@property(nonatomic, readonly) NSString *userID;
@property(nonatomic, readonly) NSString *accessToken;
@property(nonatomic, readonly) NSDate *accessTokenDate;

- (id)initWithClientId:(NSString *)clientId;
- (void)authorize:(NSString *)scope withDelegate:(id <VkontakteSessionDelegate>)delegate;
- (void)logoutWithDelegate:(id <VkontakteSessionDelegate>)delegate;

- (BOOL)isSessionValid;

- (VKRequest *)requestWithMethod:(NSString *)methodName andParams:(NSDictionary *)params andDelegate:(id <VKRequestDelegate>)delegate;
- (VKRequest *)requestWithMethod:(NSString *)methodName andDelegate:(id <VKRequestDelegate>)delegate;

@end

@protocol VkontakteSessionDelegate <NSObject>

@optional
- (void)didSuccesLogin: (Vkontakte *)vkontakte;
- (void)didCancelLogin: (Vkontakte *)vkontakte;
- (void)didErrorLogin:  (Vkontakte *)vkontakte withError:(NSError *)error;

- (void)didLogout:      (Vkontakte *)vkontakte;

@end
