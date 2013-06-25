//
//  SRViewController.m
//  NotificationView
//
//  Created by user on 12.02.13.
//  Copyright (c) 2013 Scanradar. All rights reserved.
//

#import "SRViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SRNotificationView.h"

@interface SRViewController ()

@property (nonatomic, strong)   SRNotificationView      *notificationView;

@property (nonatomic, strong)   UIButton                *showButton;
@property (nonatomic, strong)   UIButton                *hideButton;
@property (nonatomic, strong)   UIButton                *showWithoutHideButton;
@property (nonatomic, strong)   UIButton                *showWithResponseButton;
@property (nonatomic, strong)   UIButton                *showWithDiclosureButton;

//buttonsTouches
-(void)_showButtonTouch:(id)sender;
-(void)_hideButtonTouch:(id)sender;
-(void)_showWithoutHideButtonTouch:(id)sender;
-(void)_showWithResponseButtonTouch:(id)sender;
-(void)_showWithDisclosureButtonTouch:(id)sender;

@end

@implementation SRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    //setup buttons
    self.showButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.showButton addTarget:self action:@selector(_showButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.showButton setTitle:@"show" forState:UIControlStateNormal];
    [self.view addSubview:self.showButton];

    self.hideButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.hideButton addTarget:self action:@selector(_hideButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.hideButton setTitle:@"hide" forState:UIControlStateNormal];
    [self.view addSubview:self.hideButton];

    self.showWithoutHideButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.showWithoutHideButton addTarget:self action:@selector(_showWithoutHideButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.showWithoutHideButton setTitle:@"Show without hide" forState:UIControlStateNormal];
    [self.view addSubview:self.showWithoutHideButton];
    
    self.showWithResponseButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.showWithResponseButton addTarget:self action:@selector(_showWithResponseButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.showWithResponseButton setTitle:@"show With Response" forState:UIControlStateNormal];
    [self.view addSubview:self.showWithResponseButton];
    
    self.showWithDiclosureButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.showWithDiclosureButton addTarget:self action:@selector(_showWithDisclosureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.showWithDiclosureButton setTitle:@"show With Disclosure" forState:UIControlStateNormal];
    [self.view addSubview:self.showWithDiclosureButton];
}

-(void)viewWillLayoutSubviews
{
    self.showButton.frame=CGRectMake(20.f, 100, CGRectGetWidth(self.view.bounds)-40.f, 40);
    
    self.hideButton.frame=CGRectMake(CGRectGetMinX(self.showButton.frame),
                                     CGRectGetMaxY(self.showButton.frame)+10.f,
                                     CGRectGetWidth(self.showButton.frame),
                                     CGRectGetHeight(self.showButton.frame));
    
    self.showWithoutHideButton.frame=CGRectMake(CGRectGetMinX(self.showButton.frame),
                                     CGRectGetMaxY(self.hideButton.frame)+10.f,
                                     CGRectGetWidth(self.showButton.frame),
                                     CGRectGetHeight(self.showButton.frame));
    
    self.showWithResponseButton.frame=CGRectMake(CGRectGetMinX(self.showButton.frame),
                                                 CGRectGetMaxY(self.showWithoutHideButton.frame)+10.f,
                                                 CGRectGetWidth(self.showButton.frame),
                                                 CGRectGetHeight(self.showButton.frame));
    
    self.showWithDiclosureButton.frame=CGRectMake(CGRectGetMinX(self.showButton.frame),
                                                 CGRectGetMaxY(self.showWithResponseButton.frame)+10.f,
                                                 CGRectGetWidth(self.showButton.frame),
                                                 CGRectGetHeight(self.showButton.frame));
}

//buttonsTouches
-(void)_showButtonTouch:(id)sender
{
    self.notificationView=[SRNotificationView showNotificationInView:self.view title:@"Notification!"];
}

-(void)_hideButtonTouch:(id)sender
{
    [self.notificationView hide];
}



-(void)_showWithoutHideButtonTouch:(id)sender
{
#warning BE CAREFUL, YOU MUST MANUAL HIDE IT AFTER SOME DELAY OR AFTER SOME ACTION
    
    //just setting hideAfter to 0
    self.notificationView=[SRNotificationView showNotificationInView:self.view title:@"Notification without hide" hideAfter:0.f];
}


-(void)_showWithResponseButtonTouch:(id)sender
{
    //you can draw your own backgroundView
    UIView *backgroundView=[[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor=[UIColor colorWithRed:.1f green:1.f blue:0.f alpha:0.5f];
    backgroundView.layer.shadowColor=[UIColor blackColor].CGColor;
    backgroundView.layer.shadowOffset=CGSizeMake(0.f, 2.f);
    backgroundView.layer.shadowRadius=2.f;
    backgroundView.layer.shadowOpacity=.7f;
    
    self.notificationView=[SRNotificationView showNotificationInView:self.view usingBlock:^(SRNotificationView *notificationView)
    {
        //some settings like alightment can be used only inside 'showNotificationInView' method. Thats why we use block to customize any settings in notificationView 
        notificationView.backgroundView=backgroundView;
        notificationView.titleLabel.text=@"Notification With Response!";
        notificationView.alignment=SRNotificationViewAlignmentTop;
    }];
    
    //response block is used then user taps on notificationView
    self.notificationView.responseBlock=^
    {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"NotificationView" message:@"Response!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    };
}


-(void)_showWithDisclosureButtonTouch:(id)sender
{
    self.notificationView=[SRNotificationView showNotificationInView:self.view usingBlock:^(SRNotificationView *notificationView)
                           {
                               notificationView.titleLabel.text=@"Notification With Disclosure";
                               notificationView.alignment=SRNotificationViewAlignmentBottom;
                           }];
    
    //detailDisclosureBlock block is used then user taps on disclosure button
    self.notificationView.detailDisclosureBlock=^
    {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"NotificationView" message:@"Disclosure touched!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    };
}



@end
