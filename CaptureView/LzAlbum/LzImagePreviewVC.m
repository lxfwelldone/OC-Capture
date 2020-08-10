//
//  LzImagePreviewVC.m
//  CaptureView
//
//  Created by lg on 2020/8/3.
//  Copyright © 2020 lxf. All rights reserved.
//

#import "LzImagePreviewVC.h"

@interface LzImagePreviewVC ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btnBack;

@end

@implementation LzImagePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViews];
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self.mAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        self.imageView.image = [UIImage imageWithData:imageData];
    }];
    

}

- (void)addViews {
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.btnBack];
    
    self.imageView.frame = self.view.bounds;
    self.btnBack.frame = CGRectMake(20, 40, 60, 40);
}


- (UIButton *)btnBack {
    if (!_btnBack) {
        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBack setTitle:@"返回" forState:UIControlStateNormal];
        [_btnBack setBackgroundColor:UIColor.blueColor];
        [_btnBack setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_btnBack addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBack;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}



@end
