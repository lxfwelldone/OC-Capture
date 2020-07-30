//
//  ViewController.m
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import "ViewController.h"
#import "WXCameraController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *btnOpen;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self baseUI];
}


- (void)baseUI{
    self.btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.btnOpen.frame = CGRectMake(0, 0, 200, 200);
    self.btnOpen.center = self.view.center;
    
    [self.btnOpen setBackgroundColor:[UIColor cyanColor]];
    [self.btnOpen setTitle:@"bbbbb" forState:UIControlStateNormal];
    
    [self.btnOpen setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:self.btnOpen];
    
    
    [self.btnOpen addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)openCamera:(UIButton *)btn{
    WXCameraController *vc = [WXCameraController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

@end
