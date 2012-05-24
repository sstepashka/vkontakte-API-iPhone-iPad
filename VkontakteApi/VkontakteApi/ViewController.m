//
//  ViewController.m
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/23/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import "ViewController.h"
#import "Vkontakte.h"
#import "VKRequest.h"

@interface ViewController ()<VkontakteSessionDelegate, VKRequestDelegate>

@property(nonatomic, retain) Vkontakte *vkontakte;
@property(nonatomic, retain) VKRequest *request;

@end

@implementation ViewController

@synthesize vkontakte=_vkontakte, request=_request;

- (void)awakeFromNib
{
    self.vkontakte = [[[Vkontakte alloc] initWithClientId:@"2963778"] autorelease];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.vkontakte = [[[Vkontakte alloc] initWithClientId:@"2963778"] autorelease];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.vkontakte = [[[Vkontakte alloc] initWithClientId:@"2963778"] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)login:(id)sender
{
    [_vkontakte authorize:@"wall" withDelegate:self];
}

- (IBAction)logout:(id)sender
{
    [_vkontakte logoutWithDelegate:self];
}

- (IBAction)getProfile:(id)sender
{
    NSString *fields = @"uid,first_name,last_name,nickname,domain,sex,bdate,city,country,timezone,photo,photo_medium,photo_big,has_mobile,rate,contacts,education";
    VKRequest *request = [_vkontakte requestWithMethod:@"getProfiles" andParams:[NSDictionary dictionaryWithObjectsAndKeys:_vkontakte.userID, @"uid", fields, @"fields", nil] andDelegate:self];
    self.request = request;
    [_request invoke];
}

- (IBAction)captchaForce:(id)sender
{
    VKRequest *request = [_vkontakte requestWithMethod:@"captcha.force" andDelegate:self];
    self.request = request;
    [_request invoke];
}


- (void)request:(VKRequest *)request didReceiveResponse:(NSURLResponse *)response
{

}

- (void)request:(VKRequest *)request didFailWithError:(NSError *)error
{
    self.request = nil;
}

- (void)request:(VKRequest *)request didLoad:(id)result
{
    self.request = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [_request.connection cancel];
    self.request = nil;
    self.vkontakte = nil;
    [super dealloc];
}

@end
