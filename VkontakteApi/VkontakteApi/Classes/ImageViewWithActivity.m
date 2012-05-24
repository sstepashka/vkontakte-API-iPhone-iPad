//
//  ImageViewWithActivity.m
//  UrbanKandi
//
//  Created by Dmitriy Kuragin on 12/20/11.
//  Copyright (c) 2011 AZOFT. All rights reserved.
//

#import "ImageViewWithActivity.h"
#import "VKRequest.h"


@interface ImageViewWithActivity()<VKRequestDelegate>
@property(nonatomic, retain) UIActivityIndicatorView *activity;
- (void)setupDefaults;
@end

@implementation ImageViewWithActivity

@synthesize activity=_activity, imageURL=_imageURL, imageRequest=_imageRequest;

-(id)init{
    self = [super init];
    if(self){
        [self setupDefaults];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setupDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setupDefaults];
    }
    return self;
}

- (void)setupDefaults {
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.69f]];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activity = activity;
    [activity release];
    [_activity setFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    [self addSubview:_activity];
    [_activity setCenter:CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f)];
    
    [_activity setHidesWhenStopped:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    [imageView setFrame:frame];
    
    UIViewAutoresizing autoresizing = UIViewAutoresizingFlexibleLeftMargin;
    autoresizing |= UIViewAutoresizingFlexibleWidth;
    autoresizing |= UIViewAutoresizingFlexibleRightMargin;
    autoresizing |= UIViewAutoresizingFlexibleTopMargin;
    autoresizing |= UIViewAutoresizingFlexibleHeight;
    autoresizing |= UIViewAutoresizingFlexibleBottomMargin;
    
    [imageView setAutoresizingMask:autoresizing];
    
    [self addSubview:imageView];
    [imageView release];
    
    if(self.image){
        [_activity stopAnimating];
    }else{
        [_activity startAnimating];
    }
    
    VKRequest *request = [[VKRequest alloc] init];
    [request setDelegate:self];
    self.imageRequest = request;
    [request release];
}
-(void)invoke{
    [_imageRequest setUrl:_imageURL];
    [_imageRequest invoke];
}

//-(void)request:(id <RequestInterface>)request didSuccessfullWithData: (id)data{
//    UIImage *image = [UIImage imageWithData:data];
//    if(image){
//        self.image = image;
//    }else{
//        self.image = [UIImage imageNamed:@"ErrorLoadImage_2.png"];
//    }
//}
//
//-(void)request:(id <RequestInterface>)request didFailWithError: (NSError *)error{
//    self.image = [UIImage imageNamed:@"ErrorLoadImage_2.png"];
//}

- (void)request:(VKRequest *)request didFailWithError:(NSError *)error
{

}

- (void)request:(VKRequest *)request didLoad:(id)result
{
    UIImage *image = [UIImage imageWithData:result];
    self.image = image;
}

-(void)setImage:(UIImage *)image{
    [super setImage:image];
    if(self.image){
        [_activity stopAnimating];
    }else{
        [_activity startAnimating];
    }
}

-(void)dealloc{
    [_imageRequest.connection cancel];
    self.imageRequest = nil;
    self.imageURL = nil;
    self.activity = nil;
    [super dealloc];
}

@end
