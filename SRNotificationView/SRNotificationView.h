//
//  SRNotificationView.h
//  Scanradar
//
//  Created by user on 12.02.13.
//  Copyright (c) 2013 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SRNotificationViewResponseBlock)(void);


typedef enum {
    SRNotificationViewAlignmentBottom,
    SRNotificationViewAlignmentTop
} SRNotificationViewAlignment;

@interface SRNotificationView : UIView

@property (nonatomic, assign)   CGFloat                             offset;
@property (nonatomic, assign)   NSTimeInterval                      hideInterval;
@property (nonatomic, assign)   NSTimeInterval                      delayInterval;
@property (nonatomic, assign)   SRNotificationViewAlignment         alignment;

@property (nonatomic, strong)   UIView                              *backgroundView;
@property (nonatomic, readonly) UILabel                             *titleLabel;

@property (nonatomic, copy)     SRNotificationViewResponseBlock     responseBlock;
@property (nonatomic, copy)     SRNotificationViewResponseBlock     detailDisclosureBlock;

//Show default notification (gray), hide after 2.5 seg
+ (SRNotificationView*)showNotificationInView:(UIView*)view title:(NSString*)title;
+ (SRNotificationView*)showNotificationInView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)hideInterval;
+ (SRNotificationView*)showNotificationInView:(UIView *)view backgroundView:(UIView*)backgroundView title:(NSString *)title hideAfter:(NSTimeInterval)hideInterval;
//Response blocks are called when a user taps on the banner notification
+ (SRNotificationView *)showNotificationInView:(UIView *)view
                                backgroundView:(UIView*)backgroundView
                                         title:(NSString *)title
                                         delay:(NSTimeInterval)delayInterval
                                     hideAfter:(NSTimeInterval)hideInterval
                                        offset:(CGFloat)offset
                              detailDisclosureBlock:(SRNotificationViewResponseBlock)detailDisclosureBlock
                                 responseBlock:(SRNotificationViewResponseBlock)responseBlock;

+ (SRNotificationView *)showNotificationInView:(UIView *)view usingBlock:(void(^)(SRNotificationView *notificationView))notificationViewBlock;
+ (SRNotificationView *)showNotificationInView:(UIView *)view
                                    usingBlock:(void(^)(SRNotificationView *notificationView))notificationViewBlock
                                 responseBlock:(SRNotificationViewResponseBlock)responseBlock;
+ (SRNotificationView *)showNotificationInView:(UIView *)view
                                    usingBlock:(void(^)(SRNotificationView *notificationView))notificationViewBlock
                         detailDisclosureBlock:(SRNotificationViewResponseBlock)detailDisclosureBlock
                                 responseBlock:(SRNotificationViewResponseBlock)responseBlock;

//Hide
- (void)hide;

@end
