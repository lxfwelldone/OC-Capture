//
//  CameraManager.m
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import "LXFCameraManager.h"
#import <Photos/Photos.h>

@interface LXFCameraManager()<AVCaptureFileOutputRecordingDelegate>


@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, assign) AVCaptureDevicePosition position;

@property (nonatomic, strong) AVCaptureDeviceInput *inputVideo;
@property (nonatomic, strong) AVCaptureDeviceInput *inputAudio;

@property (nonatomic, strong) AVCaptureMovieFileOutput *outputMovie;
@property (nonatomic, strong) AVCaptureConnection *captureConnection;          //输入输出对象连接

//@property (nonatomic, strong) NSString *strVideoFilePath;
//@property (nonatomic, strong) NSString *strImageFilePath;

/// 播放的视频
@property (nonatomic, strong) AVPlayerItem *playerItem;



@end

@implementation LXFCameraManager

//初始化摄像头
- (instancetype)initWithPosition:(int)position
{
    self = [super init];
    if (self) {
        
        _max_duration = 10;
        if (position == 2) {
            _position = AVCaptureDevicePositionFront;
        } else {
            _position = AVCaptureDevicePositionBack;
        }
        [self setAudioSession];
        [self prepareCamera];
        
    }
    return self;
}

#pragma mark - 开放接口

// stopSession
- (void)stopSession{
    if (_captureSession) {
        [_captureSession stopRunning];
    }
}

// startSession
- (void)startSession{
    if (_captureSession) {
        [_captureSession startRunning];
    }
}


/// 切换摄像头
- (void)exchangeCameraDevice{
    [_captureSession stopRunning];
    if (_position == AVCaptureDevicePositionBack) {
        _position = AVCaptureDevicePositionFront;
    } else {
        _position = AVCaptureDevicePositionBack;
    }
    [self removeInputOutput];
    [self prepareCamera];
    [self startSession];
}


/// 开始录像
- (void)startRecord{
    if (!_captureConnection || (_outputMovie && [_outputMovie isRecording])) {
        return;
    }
    
    self.pathVideoFile = [LXFCameraManager cacheFilePath:YES];
    NSURL *urlFile = [NSURL fileURLWithPath:self.pathVideoFile];
    [self.outputMovie startRecordingToOutputFileURL:urlFile recordingDelegate:self];
}

/// 停止录像
- (void)stopRecord{
    if (_outputMovie.isRecording) {
        [_outputMovie stopRecording];
    }
}

/// 拍照
- (void)takePhoto{

    AVCaptureConnection *conn = [self.outputStillImage connectionWithMediaType:AVMediaTypeVideo];
    [self.outputStillImage captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        [self stopSession];
        NSData *dataImage = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoData:path:)]) {
            [self.delegate takePhotoData:dataImage path:nil];
        }
        
//        NSString *base64 = [dataImage base64EncodedDataWithOptions:0];
//        UIImage *image = [UIImage imageWithData:dataImage];
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//        [UIImageJPEGRepresentation(image, 1) writeToFile:self.strImageFilePath atomically:YES];
    }];
    
}

/// 开始播放
- (void)startPlay:(AVPlayerLayer *)layer{

    [self stopPlay];
    
    
    NSURL *fileUrl = [NSURL fileURLWithPath:self.pathVideoFile];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:fileUrl];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [self addObserver];
    
    [layer setPlayer:self.player];
    [self.player play];

}

/// 播放结束 重复播放
- (void)playEnd:(NSNotification *)n{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

/// 监听播放状态
- (void)addObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

/// 移除监听
- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 停止播放
- (void)stopPlay{
    if (_player) {
        [_player pause];
    }
    _player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - 准备配置

/// 准备相机
- (void)prepareCamera{
    _device = [self newDevicePosition:_position];
    [self setCameraModes];
    [self addInputOutput];
}

/// 去除输入输出流
- (void)removeInputOutput{
    [_captureSession beginConfiguration];
    [self.captureSession removeInput:_inputAudio];
    [self.captureSession removeInput:_inputVideo];
    [self.captureSession removeOutput:_outputMovie];
    [self.captureSession removeOutput:_outputStillImage];
    [_captureSession commitConfiguration];
}

/// 设置输入输出数据
- (void)addInputOutput{
    
    [_captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.inputAudio]) {
        [self.captureSession addInput:self.inputVideo];
    }
    if ([self.captureSession canAddInput:self.inputAudio]) {
        [self.captureSession addInput:self.inputAudio];
    }
    if ([self.captureSession canAddOutput:self.outputStillImage]) {
        [self.captureSession addOutput:self.outputStillImage];
    }
    if ([self.captureSession canAddOutput:self.outputMovie]) {
        [self.captureSession addOutput:self.outputMovie];
    }
    [_captureSession commitConfiguration];
    
    // 防抖功能
    if ([self.captureConnection isVideoStabilizationSupported] && self.captureConnection.activeVideoStabilizationMode == AVCaptureVideoStabilizationModeOff){
        self.captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
}

///设置相机各种模式
- (void)setCameraModes{

    NSError *error;
    [self.device lockForConfiguration:&error];
    if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [self.device setFlashMode:AVCaptureFlashModeAuto];
    }
    
    //会导致背景模糊
//    if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
//    }
//
//    会导致视频黄黄的
//    if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
//        [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
//    }
    [self.device unlockForConfiguration];

}


//后台播放音频时需要注意加以下代码，否则会获取音频设备失败
- (void)setAudioSession{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVideoRecording error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}



#pragma mark - AVCaptureFileOutputRecordingDelegate
///录制视频完成
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    //
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishRecord:error:)]) {
        [self.delegate finishRecord:outputFileURL error:error];
    }
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        PHAssetResourceCreationOptions * options = [[PHAssetResourceCreationOptions alloc] init];
//        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//
//    }];
}




/// 获取摄像头设备
/// @param position  AVCaptureDevicePosition
- (AVCaptureDevice *)deviceOnPosition:(AVCaptureDevicePosition)position  API_AVAILABLE(ios(10.2)){
     AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:[NSArray arrayWithObjects:AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera, nil] mediaType:AVMediaTypeVideo position:position];
     
     if (deviceSession.devices.count == 0) {

         deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:[NSArray arrayWithObjects:AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera, nil] mediaType:AVMediaTypeVideo position:position];
         if (deviceSession.devices.count == 0) {
             //没有可用的后置摄像头
             
             return nil;
         }
     }
     
    return [deviceSession.devices objectAtIndex:0];
}

/**
 根据位置初始化相机
 */
- (AVCaptureDevice *)newDevicePosition:(AVCaptureDevicePosition)position{
        
    AVCaptureDevice *captureDevice = nil;
    if (@available(iOS 10.2, *)){
        captureDevice = [self deviceOnPosition:position];
    }
    else if (@available(iOS 10.0, *)) {
        captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDuoCamera mediaType:AVMediaTypeVideo position:position];
        
    } else {
        //提示升级系统
        return nil;
    }
    return captureDevice;
}

- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _captureSession;
}


#pragma mark - outputStillImage
- (AVCaptureStillImageOutput *)outputStillImage{
    if (!_outputStillImage) {
        _outputStillImage = [[AVCaptureStillImageOutput alloc] init];
    }
    if (self.device.position == AVCaptureDevicePositionFront) {
        //前置摄像头一定要设置一下 要不然画面是镜像
        for (AVCaptureConnection * av in _outputStillImage.connections) {
            if (av.supportsVideoMirroring) {
                //镜像设置
                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                av.videoMirrored = YES;
            }
        }
    }
    return _outputStillImage;
}

#pragma mark - captureConnection
- (AVCaptureConnection *)captureConnection{
    return _captureConnection = _captureConnection ? : [self.outputMovie connectionWithMediaType:AVMediaTypeVideo];
}

#pragma mark - outputMovie
- (AVCaptureMovieFileOutput *)outputMovie{
    if (!_outputMovie) {
        _outputMovie = [[AVCaptureMovieFileOutput alloc] init];
        _outputMovie.maxRecordedDuration = CMTimeMake(_max_duration, 60*_max_duration);
        _outputMovie.maxRecordedFileSize = _max_duration*1024*1024;
    }
    return _outputMovie;
}

/// 视频输入
- (AVCaptureDeviceInput *)inputVideo{
    _inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    return _inputVideo;
}

/// 音频输入
- (AVCaptureDeviceInput *)inputAudio{
    if (!_inputAudio) {
        _inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    }
    return _inputAudio;
}


////视频保存路径
//+ (NSString *)strVideoFilePath{
//    return [self createFilePath:@"tt.mp4"];
//}
//
////视频保存路径
//- (NSString *)strVideoFilePath{
//    return [self createFilePath:@"tt.mp4"];
//}
////图片保存
//- (NSString *)strImageFilePath{
//    return [self createFilePath:@"cc.jpg"];
//}
//
//+ (NSString *)createFilePath:(NSString *)name{
//    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *filePath = [cachesDir stringByAppendingPathComponent:name];
//    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//    return ok?filePath:nil;
//}
//- (NSString *)createFilePath:(NSString *)name{
//    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *filePath = [cachesDir stringByAppendingPathComponent:name];
//    BOOL ok = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//    return ok?filePath:nil;
//}

#pragma mark - 压缩视频
- (void)compressVideo:(NSURL *)inputFileURL complete:(void(^)(BOOL success, NSURL* outputUrl))complete{
    NSURL *outPutUrl = [NSURL fileURLWithPath:[LXFCameraManager cacheFilePath:NO]];
    [self convertVideoQuailtyWithInputURL:inputFileURL outputURL:outPutUrl completeHandler:^(AVAssetExportSession *exportSession) {
        complete(exportSession.status == AVAssetExportSessionStatusCompleted, outPutUrl);
    }];
}

- (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
         handler(exportSession);
    }];
}

#pragma mark 获取文件大小
+ (CGFloat)getfileSize:(NSString *)filePath{
    NSFileManager *fm = [NSFileManager defaultManager];
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    CGFloat fileSize = 0;
    if ([fm fileExistsAtPath:filePath]) {
        fileSize = [[fm attributesOfItemAtPath:filePath error:nil] fileSize];
        NSLog(@"视频大小 - - - - - %fM,--------- %fKB",fileSize / (1024.0 * 1024.0),fileSize / 1024.0);
    }
    return fileSize/1024/1024;
}

#pragma mark 视频缓存目录
+ (NSString*)cacheFilePath:(BOOL)input{
    NSString *cacheDirectory = [self getCacheDirWithCreate:YES];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate *NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString *timeStr = [formatter stringFromDate:NowDate];
    NSString *put = input ? @"input" : @"output";
    NSString *path = input ? @"mov" : @"mp4";
    NSString *fileName = [NSString stringWithFormat:@"video_%@_%@.%@",timeStr,put,path];
    return [cacheDirectory stringByAppendingFormat:@"/%@", fileName];
}

+ (NSString *) getCacheDirWithCreate:(BOOL)isCreate {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    dir = [dir stringByAppendingPathComponent:@"Caches"];
    dir = [dir stringByAppendingPathComponent:@"cache"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fm fileExistsAtPath:dir isDirectory:&isDir]) {
        // 不存在
        if (isCreate) {
            [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
            return dir;
        }else {
            return @"";
        }
    }else{
        // 存在
        return dir;
    }
}


#pragma mark - 获取权限
+ (void)getCameraAuth:(void(^)(BOOL boolValue, NSString *tipText))isAuthorized{
    __weak typeof(self) instance = self;
    //获取视频权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted) {
                                         [instance getCameraAuth:isAuthorized];
                                     }else{
                                         isAuthorized(NO, @"没有获得相机权限");
                                     }
                                 }];
    }else if (authStatus == AVAuthorizationStatusAuthorized){
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            isAuthorized(granted,  @"没有获得麦克风权限");
        }];
    }else{
        isAuthorized(NO, @"没有获得相机权限");
    }
}
@end
