//
//  ViewController.m
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import "WXCameraController.h"
#import "LXFPlayerView.h"
#import "LXFCameraManager.h"
#import "LXFCameraOperateView.h"

@interface WXCameraController ()<LXFCameraOperateDelegate, LXFCameraManagerDelegate>


@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer; //预览层

@property (nonatomic, retain) LXFCameraManager *cameraManager;

@property (nonatomic, strong) LXFCameraOperateView *viewOperate;

@property (nonatomic, strong) LXFPlayerView *viewPlay;

@property (nonatomic, strong) NSURL *recordVideoUrl;
@property (nonatomic, strong) NSURL *recordVideoOutPutUrl;
@property (nonatomic, assign) BOOL videoCompressComplete;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) UIImage *imageSave;

@end

@implementation WXCameraController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self baseUI];
}

//返回上一页
- (void)back{
    if (self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - LXFCameraManagerDelegate
// 照片
- (void)takePhotoData:(NSData *)imageData path:(NSString *)path{
//    NSString *base64 = [dataImage base64EncodedDataWithOptions:0];
    self.imageSave = [UIImage imageWithData:imageData];
}

// 视频
- (void)finishRecord:(NSURL *)outputUrl error:(NSError *)error{
    [self.cameraManager stopSession];
    if (!error) {
        
        self.recordVideoUrl = outputUrl;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.viewPlay startPlayWithUrl:outputUrl];
            self.isPlaying = YES;
         });
        
        [self compressVideo];
    } else {
        
    }
}


- (void)saveImage{
    if (self.imageSave) {
        UIImageWriteToSavedPhotosAlbum(self.imageSave, nil, nil, nil);
//        [UIImageJPEGRepresentation(image, 1) writeToFile:self.strImageFilePath atomically:YES];
    }
}

#pragma mark - 处理视频
/// 压缩视频
- (void)compressVideo{
    __weak typeof(self) instance = self;
    [self.cameraManager compressVideo:self.recordVideoUrl complete:^(BOOL success, NSURL *outputUrl) {
        if (success && outputUrl) {
            instance.recordVideoOutPutUrl = outputUrl;
        }
        instance.videoCompressComplete = YES;
    }];
}

/// 保存视频
- (void)saveVideo{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([self.recordVideoUrl path])) {
        //保存视频到相簿
        UISaveVideoAtPathToSavedPhotosAlbum([self.recordVideoUrl path], self,
                                            @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存视频完成");
}

#pragma mark - LXFCameraOperateDelegate
- (void)toDo:(LXFCameraOperation)operation{
    switch (operation) {
        case LXFCameraOperationBack:
            [self back];
            break;
         
        case LXFCameraOperationExchange:
            [self.cameraManager exchangeCameraDevice];
            break;
            
        case LXFCameraOperationRedo:
            self.previewLayer.hidden = NO;

            if (self.isPlaying) {
                self.isPlaying = NO;
                [self.viewPlay stopPlay];
            }
            [self.cameraManager startSession];
            break;
        
        case LXFCameraOperationUse:
            if (self.isPlaying) {
                self.isPlaying = NO;
                [self saveVideo];
            } else {
                [self saveImage];
            }
            self.previewLayer.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (void)toDo:(LXFCameraOperation)operation time:(NSTimeInterval)time{
        switch (operation) {
                
            case LXFCameraOperationTakePhoto:
                
                [self.cameraManager takePhoto];
                break;
                
            case LXFCameraOperationStartRecord:
                self.videoCompressComplete = NO;
                self.recordVideoOutPutUrl = nil;
                [self.viewOperate hideWhenLongPress:YES];
                [self.cameraManager startRecord];
                break;
                
            case LXFCameraOperationStopRecord:
                [self.cameraManager stopRecord];
                
                self.viewPlay.hidden = NO;
                self.previewLayer.hidden = YES;
                [self.viewOperate showOperates:YES];

            default:
                break;
        }
}


#pragma mark - UI
- (void)baseUI{
    
    _cameraManager = [[LXFCameraManager alloc] initWithPosition:AVCaptureDevicePositionBack];
    _cameraManager.delegate = self;
    
    [self.view.layer addSublayer:self.previewLayer];
    self.previewLayer.backgroundColor = UIColor.redColor.CGColor;
    
    [self.view addSubview:self.viewPlay];
    [self.view addSubview:self.viewOperate];
    //开始读取
    [self.cameraManager startSession];
}


- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraManager.captureSession];
        _previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (LXFCameraOperateView *)viewOperate{
    if (!_viewOperate) {
        _viewOperate = [[LXFCameraOperateView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _viewOperate.delegate = self;
    }
    return _viewOperate;
}

- (LXFPlayerView *)viewPlay{
    if (!_viewPlay) {
        _viewPlay = [[LXFPlayerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _viewPlay.hidden = YES;
    }
    return _viewPlay;
}

@end
