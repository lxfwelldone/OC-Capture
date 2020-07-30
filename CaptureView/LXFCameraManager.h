//
//  CameraManager.h
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol LXFCameraManagerDelegate <NSObject>

- (void)takePhotoData:(NSData *)imageData path:(NSString *)path;

- (void)finishRecord:(NSURL *)outputUrl error:(NSError *)error;

@end


@interface LXFCameraManager : NSObject

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureStillImageOutput *outputStillImage API_AVAILABLE(ios(9.0));

@property (nonatomic, assign) NSTimeInterval max_duration;

@property (nonatomic, weak) id <LXFCameraManagerDelegate> delegate;

/// 播放器
@property (nonatomic, strong) AVPlayer *player;

//视频路径
@property (nonatomic, strong) NSString * pathVideoFile;


///初始化 2=前置摄像头，否则是后置
- (instancetype)initWithPosition:(int)position;


// stopSession
- (void)stopSession;

// startSession
- (void)startSession;

/// 拍照
- (void)takePhoto;


/// 开始录像
- (void)startRecord;

/// 停止录像
- (void)stopRecord;

/// 压缩视频
- (void)compressVideo:(NSURL *)inputFileURL complete:(void(^)(BOOL success, NSURL* outputUrl))complete;

/// 播放视频
- (void)startPlay:(AVPlayerLayer *)layer;


/// 停止播放
- (void)stopPlay;


///切换相机
- (void)exchangeCameraDevice;
//
////视频保存路径
//- (NSString *)strVideoFilePath;
//
////视频保存路径
//+ (NSString *)strVideoFilePath;

@end
