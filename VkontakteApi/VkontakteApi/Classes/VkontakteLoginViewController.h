//
//  VkontakteLoginViewController.h
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/23/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Vkontakte;

@interface VkontakteLoginViewController : UIViewController

@property(nonatomic, retain) IBOutlet UIWebView *webView;

@property(nonatomic, copy) NSString *scope;
@property(nonatomic, copy) NSString *clientId;

@property(nonatomic, assign) Vkontakte *vkontakte;

@end

