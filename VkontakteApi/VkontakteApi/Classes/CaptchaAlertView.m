//
//  CaptchaAlertView.m
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/24/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import "CaptchaAlertView.h"
#import "ImageViewWithActivity.h"

@implementation CaptchaAlertView

@synthesize captchSig=_captchSig, captchUrl=_captchUrl;

- (id)init{
    self = [super init];
    if (self) {
        [self setTitle:@"Captcha"];
        [self setMessage:@"\n\n\n"];
    }
    return self;
}

- (void)show
{
    ImageViewWithActivity *imageView = [[ImageViewWithActivity alloc] initWithFrame:CGRectMake(77.0, 37.6, 130.0, 50.0)];
    [imageView setImageURL:_captchUrl];
    
    [imageView invoke];
    
    [self addSubview:imageView];
    
    [imageView release];
    
    UITextField *myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(12.0, 90.0, 260.0, 29.0)] autorelease];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.tag = 33;
    
    [self addSubview:myTextField];
    
    [self addButtonWithTitle:@"Cancel"];
    [self addButtonWithTitle:@"OK"];
    
    [self setCancelButtonIndex:0];
    
    [super show];
}

- (void)dealloc
{
    self.captchSig = nil;
    self.captchUrl = nil;
    [super dealloc];
}

@end
