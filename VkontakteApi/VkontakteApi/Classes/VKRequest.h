//
//  VKRequest.h
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/24/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VKRequestDelegate;

@interface VKRequest : NSObject {
}

@property(nonatomic, copy) NSMutableData *responcedData;
@property(nonatomic, assign) id <VKRequestDelegate> delegate;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, copy) NSDictionary *params;
@property(nonatomic, copy) NSString* httpMethod;
@property(nonatomic, copy) NSString *url;

- (BOOL)loading;
- (void)invoke;

@end

@protocol VKRequestDelegate <NSObject>

@optional
- (void)request:(VKRequest *)request didReceiveResponse:(NSURLResponse *)response;
- (void)request:(VKRequest *)request didFailWithError:(NSError *)error;
- (void)request:(VKRequest *)request didLoad:(id)result;

@end
