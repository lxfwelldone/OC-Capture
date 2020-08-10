//
//  LXFPlayerView.m
//  CaptureView
//
//  Created by lxf2013 on 2020/1/2.
//  Copyright © 2020 lxf. All rights reserved.
//

#import "LXFPlayerView.h"


@interface LXFPlayerView()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation LXFPlayerView



/// 停止播放
- (void)stopPlay{
    [self.player pause];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/// 播放
/// @param playUrl playUrl
- (void)startPlayWithUrl:(NSURL *)playUrl{
    if (!self.player) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:playUrl];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addObserverToPlayerItem:playerItem];
    }
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.playerLayer];

    [self.player play];
}


- (void)dealloc{
    [self stopPlay];
}


- (void)playbackFinished:(NSNotification *)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}


@end
