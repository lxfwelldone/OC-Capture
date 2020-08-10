//
//  LzVideoPreviewVC.m
//  CaptureView
//
//  Created by lg on 2020/8/3.
//  Copyright © 2020 lxf. All rights reserved.
//

#import "LzVideoPreviewVC.h"

@interface LzVideoPreviewVC ()
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) UIImageView *imgBack;
@property (nonatomic, strong) UIImageView *imgUse;

@end

@implementation LzVideoPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.frame = self.view.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.playerLayer];
    
    [self.view addSubview:self.imgBack];
    [self.view addSubview:self.imgUse];
    CGFloat sw = UIScreen.mainScreen.bounds.size.width;
    CGFloat sh = UIScreen.mainScreen.bounds.size.height;
    CGFloat imgw = 50;
    self.imgBack.frame = CGRectMake(100, sh-imgw-20, imgw, imgw);
    self.imgUse.frame = CGRectMake(sw-100-imgw, sh-imgw-20, imgw, imgw);
    
    if (self.mAsset) {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:self.mAsset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.playerLayer.player = self.player;
            
            [self addObserverToPlayerItem:playerItem];
            [self.player play];
        }];
    }

    
    self.imgBack.userInteractionEnabled = YES;
    self.imgUse.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.imgBack addGestureRecognizer:tap1];
    
    
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(use)];
    [self.imgUse addGestureRecognizer:tap2];
}

- (void)use {
    if (self.useVideo) {
        self.useVideo(self.mAsset);
    }
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)stop{
    if (_player) {
        [_player pause];
    }
}



- (void)playbackFinished:(NSNotification *)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)dealloc{
    [self.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (UIImageView *)imgBack {
    if (!_imgBack) {
        _imgBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_redo"]];
    }
    return _imgBack;
}

- (UIImageView *)imgUse {
    if (!_imgUse) {
        _imgUse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_use"]];
    }
    return _imgUse;
}


@end
