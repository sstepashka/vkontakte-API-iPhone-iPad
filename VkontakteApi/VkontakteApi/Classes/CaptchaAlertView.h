//
//  CaptchaAlertView.h
//  VkontakteApi
//
//  Created by Dmitriy Kuragin on 5/24/12.
//  Copyright (c) 2012 AZOFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptchaAlertView : UIAlertView

@property(nonatomic, copy) NSString *captchSig;
@property(nonatomic, copy) NSString *captchUrl;

@end
