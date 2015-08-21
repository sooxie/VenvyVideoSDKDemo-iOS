//
//  MainViewController.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 15/6/8.
//  Copyright (c) 2015年 VenvyVideo. All rights reserved.
//

#import "MainViewController.h"
#import <VenvyVideoSDK/VVSDKPlayerViewController.h>
#import "VVViewPlayerViewController.h"

@interface MainViewController ()

@property (nonatomic) UITextField *urlTextField;
@property (nonatomic) UIButton *startButton;
@property (nonatomic) UIButton *localButton;
@property (nonatomic) UIButton *liveButton;
@property (nonatomic) UIButton *startViewButton;
@property (nonatomic) UIButton *localViewButton;
@property (nonatomic) UIButton *liveViewButton;

@end

@implementation MainViewController
@synthesize urlTextField;
@synthesize startButton,localButton,liveButton;
@synthesize startViewButton,localViewButton,liveViewButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 30, self.view.frame.size.width - 20, 50)];
    [urlTextField.layer setBorderColor:[UIColor blackColor].CGColor];
    [urlTextField.layer setBorderWidth:1];
    [urlTextField setFont:[UIFont systemFontOfSize:14]];

    
    [self.view addSubview:urlTextField];
    
    startButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 10 - 40 - 80, CGRectGetMaxY(urlTextField.frame) + 20, 80, 40)];
    [startButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [startButton setTitle:@"八大网站视频" forState:UIControlStateNormal];
    [startButton setBackgroundColor:[UIColor blackColor]];
    [startButton addTarget:self action:@selector(startButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    localButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(startButton.frame) + 10, CGRectGetMaxY(urlTextField.frame) + 20, 80, 40)];
    [localButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [localButton setTitle:@"直接访问视频" forState:UIControlStateNormal];
    [localButton setBackgroundColor:[UIColor blackColor]];
    [localButton addTarget:self action:@selector(localButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localButton];
    
    liveButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(localButton.frame) + 10, CGRectGetMaxY(urlTextField.frame) + 20, 80, 40)];
    [liveButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [liveButton setTitle:@"直播" forState:UIControlStateNormal];
    [liveButton setBackgroundColor:[UIColor blackColor]];
    [liveButton addTarget:self action:@selector(liveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:liveButton];
    
    startViewButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(startButton.frame), CGRectGetMaxY(startButton.frame) + 20, 80, 40)];
    [startViewButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [startViewButton setTitle:@"八大网站view" forState:UIControlStateNormal];
    [startViewButton setBackgroundColor:[UIColor blackColor]];
    [startViewButton addTarget:self action:@selector(startViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startViewButton];
    
    localViewButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(localButton.frame), CGRectGetMaxY(localButton.frame) + 20, 80, 40)];
    [localViewButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [localViewButton setTitle:@"直接访问view" forState:UIControlStateNormal];
    [localViewButton setBackgroundColor:[UIColor blackColor]];
    [localViewButton addTarget:self action:@selector(localViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localViewButton];
    
    liveViewButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(liveButton.frame), CGRectGetMaxY(liveButton.frame) + 20, 80, 40)];
    [liveViewButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [liveViewButton setTitle:@"直播view" forState:UIControlStateNormal];
    [liveViewButton setBackgroundColor:[UIColor blackColor]];
    [liveViewButton addTarget:self action:@selector(liveViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:liveViewButton];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void) startButtonTapped:(id)sender {
    [urlTextField resignFirstResponder];
    if([urlTextField.text isEqualToString:@""] || urlTextField.text == nil) {
        return;
    }
    else {
        VVSDKPlayerViewController *player = [[VVSDKPlayerViewController alloc] initWithUrl:urlTextField.text VideoType:0 LocalVideoTitle:nil];
        
        [self presentViewController:player animated:YES completion:nil];
    }
}

- (void) localButtonTapped:(id)sender {
    [urlTextField resignFirstResponder];
    if([urlTextField.text isEqualToString:@""] || urlTextField.text == nil) {
        return;
    }
    else {
        VVSDKPlayerViewController *player = [[VVSDKPlayerViewController alloc] initWithUrl:urlTextField.text VideoType:1 LocalVideoTitle:@"这是本地视频测试"];
        
        [self presentViewController:player animated:YES completion:nil];
    }
}

- (void) liveButtonTapped:(id)sender {
    [urlTextField resignFirstResponder];
    if([urlTextField.text isEqualToString:@""] || urlTextField.text == nil) {
        return;
    }
    else {
        VVSDKPlayerViewController *player = [[VVSDKPlayerViewController alloc] initWithUrl:urlTextField.text VideoType:2 LocalVideoTitle:@"这是直播视频测试"];
        
        [self presentViewController:player animated:YES completion:nil];
    }
}

- (void) startViewButtonTapped:(id)sender {
    [urlTextField resignFirstResponder];
    if([urlTextField.text isEqualToString:@""] || urlTextField.text == nil) {
        return;
    }
    else {
        VVViewPlayerViewController *player = [[VVViewPlayerViewController alloc] initWithUrl:urlTextField.text VideoType:0 LocalVideoTitle:nil];

        [self presentViewController:player animated:YES completion:nil];
    }
}

- (void) localViewButtonTapped:(id)sender {
    [urlTextField resignFirstResponder];
    if([urlTextField.text isEqualToString:@""] || urlTextField.text == nil) {
        return;
    }
    else {
        VVViewPlayerViewController *player = [[VVViewPlayerViewController alloc] initWithUrl:urlTextField.text VideoType:1 LocalVideoTitle:@"这是本地视频测试"];
        [self presentViewController:player animated:YES completion:nil];
    }
}

- (void) liveViewButtonTapped:(id)sender {
    [urlTextField resignFirstResponder];
    if([urlTextField.text isEqualToString:@""] || urlTextField.text == nil) {
        return;
    }
    else {
        VVViewPlayerViewController *player = [[VVViewPlayerViewController alloc] initWithUrl:urlTextField.text VideoType:2 LocalVideoTitle:@"这是直播视频测试"];
        [self presentViewController:player animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *
 *  viewWillLayoutSubviews是为了适应横竖屏
 *  如果只需竖屏请打开shouldAutorotate,supportedInterfaceOrientations,preferredInterfaceOrientationForPresentation并注释viewWillLayoutSubviews
 *  如需要横竖屏请打开viewWillLayoutSubviews并注释关于旋转的或者修改旋转的方法
 *
 */

//- (void) viewWillLayoutSubviews {
//    [urlTextField setFrame:CGRectMake(10, 30, self.view.frame.size.width - 20, 50)];
//    [startButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 40 - 10 - 80, CGRectGetMaxY(urlTextField.frame) + 20, 80, 40)];
//    [localButton setFrame:CGRectMake(CGRectGetMaxX(startButton.frame) + 10, CGRectGetMaxY(urlTextField.frame) + 20, 80, 40)];
//    [liveButton setFrame:CGRectMake(CGRectGetMaxX(localButton.frame) + 10, CGRectGetMaxY(urlTextField.frame) + 20, 80, 40)];
//    [startViewButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 40 - 10 - 80, CGRectGetMaxY(startButton.frame) + 20, 80, 40)];
//    [localViewButton setFrame:CGRectMake(CGRectGetMaxX(startViewButton.frame) + 10, CGRectGetMaxY(localButton.frame) + 20, 80, 40)];
//    [liveViewButton setFrame:CGRectMake(CGRectGetMaxX(localViewButton.frame) + 10, CGRectGetMaxY(liveButton.frame) + 20, 80, 40)];
//}


//需要present到SDKViewController必须shouldAutorotate设为YES,不然8.1,8.2显示不正常

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
