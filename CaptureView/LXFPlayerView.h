//
//  LXFPlayerView.h
//  CaptureView
//
//  Created by lxf2013 on 2020/1/2.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LXFPlayerView : UIView

- (void)stopPlay;

- (void)startPlayWithUrl:(NSURL *)playUrl;

@end

