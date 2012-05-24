//
//  ImageViewWithActivity.h
//  UrbanKandi
//
//  Created by Dmitriy Kuragin on 12/20/11.
//  Copyright (c) 2011 AZOFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VKRequest;

@interface ImageViewWithActivity : UIImageView

@property(nonatomic, copy) NSString *imageURL;
@property(nonatomic, retain) VKRequest *imageRequest;

-(void)invoke;

@end
