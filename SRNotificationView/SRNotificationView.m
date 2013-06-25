//
//  SRNotificationView.m
//  Scanradar
//
//  Created by user on 12.02.13.
//  Copyright (c) 2013 user. All rights reserved.
//

#import "SRNotificationView.h"
#import <QuartzCore/QuartzCore.h>

#define NOTIFICATION_HEIGHT                 50.0f
#define NOTIFICATION_DEFAULT_HIDE_INTERVAL  2.5f

static NSMutableArray *notificationsQueue = nil;       // Global notification queue

@interface SRNotificationView()
{
    UILabel                             *_titleLabel;
}

@property (nonatomic, strong)   UIView      *parentView;
@property (nonatomic, strong)   UIButton    *detailDisclosureButton;

- (void) showAfterDelay:(NSTimeInterval)delayInterval;
//touches
-(void)_detailDisclosureButtonTouch:(id)sender;
-(void)_notificationViewTouch:(id)sender;
@end

@implementation SRNotificationView

@synthesize titleLabel=_titleLabel;

////////////////////////////////////////////////////////////////////////
#pragma mark - View LifeCycle
////////////////////////////////////////////////////////////////////////


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor lightGrayColor];
        self.alpha = 0.0f;
        self.autoresizesSubviews=YES;
        
        //Title Label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectInset((CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), NOTIFICATION_HEIGHT)),10.f,0.f)];
        _titleLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Neue"size:15];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.alpha = 0.0;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled=NO;
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_notificationViewTouch:)];
        tapRecognizer.numberOfTapsRequired=1;
        tapRecognizer.numberOfTouchesRequired=1;
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}




////////////////////////////////////////////////////////////////////////
#pragma mark - Show
////////////////////////////////////////////////////////////////////////

+(SRNotificationView*)showNotificationInView:(UIView*)view title:(NSString*)title
{
    return [SRNotificationView showNotificationInView:view title:title hideAfter:NOTIFICATION_DEFAULT_HIDE_INTERVAL];
}

+ (SRNotificationView *)showNotificationInView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)hideInterval
{
    return [SRNotificationView showNotificationInView:view backgroundView:nil title:title hideAfter:hideInterval];
}

+ (SRNotificationView *)showNotificationInView:(UIView *)view backgroundView:(UIView*)backgroundView title:(NSString *)title hideAfter:(NSTimeInterval)hideInterval
{
    return [SRNotificationView showNotificationInView:view backgroundView:backgroundView title:title delay:0.f hideAfter:hideInterval offset:0.f detailDisclosureBlock:nil responseBlock:nil];
}

+ (SRNotificationView *)showNotificationInView:(UIView *)view
                                backgroundView:(UIView*)backgroundView
                                         title:(NSString *)title
                                         delay:(NSTimeInterval)delayInterval
                                     hideAfter:(NSTimeInterval)hideInterval
                                        offset:(CGFloat)offset
                         detailDisclosureBlock:(SRNotificationViewResponseBlock)detailDisclosureBlock
                                 responseBlock:(SRNotificationViewResponseBlock)responseBlock
{
    return [SRNotificationView showNotificationInView:view usingBlock:^(SRNotificationView *notificationView)
            {
                notificationView.titleLabel.text=title;
                notificationView.hideInterval = hideInterval;
                notificationView.offset = offset;
                notificationView.backgroundView=backgroundView;
                notificationView.responseBlock=responseBlock;
                notificationView.detailDisclosureBlock=detailDisclosureBlock;
            }];
}



+ (SRNotificationView *)showNotificationInView:(UIView *)view usingBlock:(void(^)(SRNotificationView*))notificationViewBlock
{
    return [SRNotificationView showNotificationInView:view usingBlock:notificationViewBlock detailDisclosureBlock:nil responseBlock:nil];
}



+ (SRNotificationView *)showNotificationInView:(UIView *)view
                                    usingBlock:(void(^)(SRNotificationView *notificationView))notificationViewBlock
                                 responseBlock:(SRNotificationViewResponseBlock)responseBlock
{
    return [SRNotificationView showNotificationInView:view usingBlock:notificationViewBlock detailDisclosureBlock:nil responseBlock:responseBlock];
}



+ (SRNotificationView *)showNotificationInView:(UIView *)view
                                    usingBlock:(void(^)(SRNotificationView *notificationView))notificationViewBlock
                         detailDisclosureBlock:(SRNotificationViewResponseBlock)detailDisclosureBlock
                                 responseBlock:(SRNotificationViewResponseBlock)responseBlock
{
    SRNotificationView *notificationView=[[self.class alloc] initWithFrame:CGRectMake(0, -NOTIFICATION_HEIGHT, view.bounds.size.width, NOTIFICATION_HEIGHT)];
    notificationView.parentView = view;
    //setting default values
    notificationView.hideInterval=NOTIFICATION_DEFAULT_HIDE_INTERVAL;
    notificationView.delayInterval=0.f;
    notificationView.offset=0.f;
    notificationView.detailDisclosureBlock=detailDisclosureBlock;
    notificationView.responseBlock=responseBlock;
    
    
    if (notificationViewBlock)
        notificationViewBlock(notificationView);

    if(!notificationsQueue)
        notificationsQueue = [NSMutableArray array];
    
    if (notificationView.hideInterval>0)
        [notificationsQueue addObject:notificationView];
    
    [notificationView showAfterDelay:notificationView.delayInterval];
    
    return notificationView;
}






#pragma mark - Properties -

-(void)setBackgroundView:(UIView *)backgroundView
{
    if (_backgroundView)
        [_backgroundView removeFromSuperview];
    
    _backgroundView=backgroundView;
    _backgroundView.frame=self.bounds;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.userInteractionEnabled=NO;
    [self insertSubview:_backgroundView belowSubview:self.titleLabel];
}


-(void)setDetailDisclosureBlock:(SRNotificationViewResponseBlock)detailDisclosureBlock
{
    _detailDisclosureBlock=[detailDisclosureBlock copy];
    
    if (detailDisclosureBlock && !self.detailDisclosureButton)
    {
        self.detailDisclosureButton=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [self.detailDisclosureButton addTarget:self action:@selector(_detailDisclosureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        self.detailDisclosureButton.frame=CGRectMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(self.detailDisclosureButton.bounds)-10.f,
                                                     CGRectGetMidY(self.bounds)-CGRectGetHeight(self.detailDisclosureButton.bounds)/2,
                                                     CGRectGetWidth(self.detailDisclosureButton.bounds),
                                                     CGRectGetHeight(self.detailDisclosureButton.bounds));
        
        self.titleLabel.frame = CGRectMake(10.f, 0.f, self.bounds.size.width -50, NOTIFICATION_HEIGHT);

        [self insertSubview:self.detailDisclosureButton aboveSubview:self.titleLabel];
    }
}




#pragma mark - Touches -

-(void)_detailDisclosureButtonTouch:(id)sender
{
    if (self.detailDisclosureBlock)
        self.detailDisclosureBlock();
}

-(void)_notificationViewTouch:(id)sender
{
    if (self.responseBlock)
    {
        self.responseBlock();
        [self hide];
    }
}




#pragma mark -


- (void) showAfterDelay:(NSTimeInterval)delayInterval
{
    [self.parentView addSubview:self];
    
    if (self.alignment==SRNotificationViewAlignmentTop)
    {
        //if parent view is a UIWindow, check if the status bar is showing (and offset the view accordingly)
        double statusBarOffset = ([self.parentView isKindOfClass:[UIWindow class]] && (! [[UIApplication sharedApplication] isStatusBarHidden])) ? [[UIApplication sharedApplication] statusBarFrame].size.height : 0.0;
        
        if ([self.parentView isKindOfClass:[UIView class]] && ![self.parentView isKindOfClass:[UIWindow class]])
        {
            statusBarOffset = 0.f;
        }
        
        self.offset = fmax(self.offset, statusBarOffset);

        //Animation
        self.frame = CGRectMake(0.f,
                                -NOTIFICATION_HEIGHT,
                                self.frame.size.width,
                                NOTIFICATION_HEIGHT);
    } else
    if (self.alignment==SRNotificationViewAlignmentBottom)
    {
        self.frame = CGRectMake(0.0,
                                CGRectGetHeight(self.parentView.frame),
                                self.frame.size.width,
                                0.f);
    }
    
    [UIView animateWithDuration:0.5f
                          delay:delayInterval
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 1.0;
                         
                         if (self.alignment==SRNotificationViewAlignmentTop)
                             self.frame = CGRectMake(0.f,
                                                     self.offset,
                                                     self.frame.size.width,
                                                     NOTIFICATION_HEIGHT);
                         
                         if (self.alignment==SRNotificationViewAlignmentBottom)
                         self.frame = CGRectMake(0.0,
                                                 CGRectGetHeight(self.parentView.frame)-NOTIFICATION_HEIGHT-self.offset,
                                                 self.frame.size.width,
                                                 NOTIFICATION_HEIGHT);
                         
                         
                         
                         self.titleLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             //Hide
                             if (self.hideInterval > 0)
                                 [self performSelector:@selector(hide) withObject:self.parentView afterDelay:self.hideInterval];
                         }
                     }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Hide
////////////////////////////////////////////////////////////////////////

- (void)hide
{
    [UIView animateWithDuration:0.4f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0;
                         self.titleLabel.alpha = 0.0;
                         
                         if (self.alignment==SRNotificationViewAlignmentTop)
                             self.frame = CGRectMake(0.0,
                                                     -NOTIFICATION_HEIGHT,
                                                     self.frame.size.width,
                                                     NOTIFICATION_HEIGHT);
                         
                         if (self.alignment==SRNotificationViewAlignmentBottom)
                         self.frame = CGRectMake(0.0,
                                                 CGRectGetHeight(self.parentView.frame),
                                                 self.frame.size.width,
                                                 NOTIFICATION_HEIGHT);
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1f];
                             
                             // Remove this notification from the queue
                             [notificationsQueue removeObjectIdenticalTo:self];
                             
                             // Show the next notification in the queue
                             if(notificationsQueue.count)
                             {
                                 SRNotificationView *nextNotification = [notificationsQueue objectAtIndex:0];
                                 [nextNotification showAfterDelay:0];
                             }
                         }
                     }];
}

@end
