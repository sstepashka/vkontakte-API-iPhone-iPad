//
//  VKRequest.m
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/24/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import "VKRequest.h"
#import "VkontakteConstants.h"
#import "SBJson.h"
#import "CaptchaAlertView.h"

@interface VKRequest() <NSURLConnectionDataDelegate, UIAlertViewDelegate>

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod;

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error;
- (void)failWithError:(NSError *)error;

@end

@implementation VKRequest

@synthesize delegate=_delegate, connection=_connection, params=_params, httpMethod=_httpMethod, url=_url, responcedData=_responcedData;

- (id)init
{
    self = [super init];
    if (self) {
        self.httpMethod = @"GET";
        self.responcedData = [NSMutableData data];
    }
    return self;
}

- (BOOL)loading
{
    return !!_connection;
}

- (void)invoke
{
    NSString* url = [[self class] serializeURL:_url params:_params httpMethod:_httpMethod];
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:kTimeoutInterval];
//    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    
    [request setHTTPMethod:self.httpMethod];
//    if ([self.httpMethod isEqualToString: @"POST"]) {
//        NSString* contentType = [NSString
//                                 stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
//        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
//        
//        [request setHTTPBody:[self generatePostBody]];
//    }
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responcedData = [[NSMutableData alloc] init];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([_delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [_delegate request:self didReceiveResponse:httpResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responcedData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleResponseData:_responcedData];

    [_connection release];
    _connection = nil;
}

- (void)handleResponseData:(NSData *)data {
    if ([_delegate respondsToSelector:@selector(request:didLoad:)] ||
        [_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            NSError* error = nil;
            id result = [self parseJsonResponse:data error:&error];

            if (error) {
                [self failWithError:error];
            } else if ([_delegate respondsToSelector: @selector(request:didLoad:)]) {
                if (result && [result isKindOfClass:[NSDictionary class]]) {
                    if([result objectForKey:@"error"]) {
                        if([[[result objectForKey:@"error"] objectForKey:@"error_code"] intValue] == 14) {
                            //captcha
                            NSDictionary *errorDict = [result objectForKey:@"error"];
                            NSString *captchaUrl = [errorDict objectForKey:@"captcha_img"];
                            NSString *captchaSig = [errorDict objectForKey:@"captcha_sid"];
                            
                            CaptchaAlertView *captchaAlertView = [[CaptchaAlertView alloc] init];
                            captchaAlertView.captchSig = captchaSig;
                            captchaAlertView.captchUrl = captchaUrl;
                            
                            [captchaAlertView setDelegate:self];
                            
                            [captchaAlertView show];
                            [captchaAlertView release];
                            return;
                        }
                    }
                }
                [_delegate request:self didLoad:(result == nil ? data : result)];
            }
        }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 1) {
        alertView.delegate = nil;
        CaptchaAlertView *captchaAlertView = (CaptchaAlertView *)alertView;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
        [params setObject:captchaAlertView.captchSig forKey:@"captcha_sid"];
        
        UITextField *myTextField = (UITextField *)[captchaAlertView viewWithTag:33];
        
        [params setObject:myTextField.text?:@"" forKey:@"captcha_user"];
        
        [self invoke];
    } else {
        if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            NSString *captchaErrorText = @"Entering captcha cancelled";
            NSError *error = [NSError errorWithDomain:captchaErrorText code:kVKCaptchaCancelErrorCode userInfo:nil];
            [_delegate request:self didFailWithError:error];
        }
    }
}

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error
{
    NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id repr = [parser objectWithString:dataString];
    [parser release];
    if (!repr) {
        NSLog(@"-JSONValue failed. Error is: %@", parser.error);
        *(error) = nil;
        return nil;
    }
    return repr;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self failWithError:error];
    self.connection = nil;
}

- (void)failWithError:(NSError *)error
{
    if (_delegate) {
        [_delegate request:self didFailWithError:error];
    }
}

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod {
    
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            if ([httpMethod isEqualToString:@"GET"]) {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        [escaped_value release];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

- (void)dealloc
{
    [_connection cancel];
    self.responcedData = nil;
    self.url = nil;
    self.delegate = nil;
    self.connection = nil;
    self.params = nil;
    self.httpMethod = nil;
    [super dealloc];
}

@end
