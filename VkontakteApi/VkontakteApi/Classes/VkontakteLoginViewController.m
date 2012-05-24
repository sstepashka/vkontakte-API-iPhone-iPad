//
//  VkontakteLoginViewController.m
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/23/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import "VkontakteLoginViewController.h"
#import "VkontakteConstants.h"
#import "Vkontakte.h"

@interface VkontakteLoginViewController ()<UIWebViewDelegate>

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str;

@end

@implementation VkontakteLoginViewController

@synthesize webView=_webView, scope=_scope, clientId=_clientId, vkontakte=_vkontakte;

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *authLink = [NSString stringWithFormat:@"http://api.vk.com/oauth/authorize?client_id=%@&scope=%@&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token", _clientId, _scope];
    
    NSURL *url = [NSURL URLWithString:authLink];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)aWbView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *URL = [request URL];
    // if user pressed cancel
    if ([[URL absoluteString] isEqualToString:@"http://api.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]) {
        if([_vkontakte.delegate respondsToSelector:@selector(didCancelLogin:)])
            [_vkontakte.delegate didCancelLogin:_vkontakte];
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    
	NSLog(@"Request: %@", [URL absoluteString]); 
	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([_webView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) {
        NSString *accessToken = [self stringBetweenString:@"access_token=" 
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        
        NSLog(@"User id: %@", user_id);
        
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:kVKUserIDKey];
        }
        
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kVKAccesToken];
            // Сохраняем дату получения токена. Параметр expires_in=86400 в ответе ВКонтакта, говорит сколько будет действовать токен.
            // В данном случае, это для примера, мы можем проверять позднее истек ли токен или нет
            
            NSString *expiresTime = [self stringBetweenString:@"expires_in=" 
                                                    andString:@"&" 
                                                  innerString:[[[webView request] URL] absoluteString]];
            
            NSDate *expiresDate = [NSDate distantFuture];
            if (expiresTime) {
                NSInteger expTime = [expiresTime intValue];
                if (expTime) {
                    expiresDate = [NSDate dateWithTimeIntervalSinceNow:expTime];
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:expiresDate forKey:kVKAccesTokenDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSLog(@"vkWebView response: %@",[[[webView request] URL] absoluteString]);
        if([_vkontakte.delegate respondsToSelector:@selector(didSuccesLogin:)])
            [_vkontakte.delegate didSuccesLogin:_vkontakte];
        [self dismissModalViewControllerAnimated:YES];
    } else if ([_webView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound)
    {
        NSLog(@"Error: %@", _webView.request.URL.absoluteString);
        if([_vkontakte.delegate respondsToSelector:@selector(didErrorLogin:withError:)])
            [_vkontakte.delegate didErrorLogin:_vkontakte withError:[NSError errorWithDomain:[NSString stringWithFormat: @"vkontakte error url:%@", _webView.request.URL.absoluteString] code:-9999 userInfo:nil]];
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"vkWebView Error: %@", [error localizedDescription]);
    [_vkontakte.delegate didErrorLogin:_vkontakte withError:error];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Methods

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str 
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    self.vkontakte = nil;
    self.scope = nil;
    self.clientId = nil;
    self.webView = nil;
    [super dealloc];
}

@end
