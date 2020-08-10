//
//  ViewController.m
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import "ViewController.h"
#import "WXCameraController.h"
#import "LzAlbumVC.h"
#import "LzJsAsset.h"

@import MobileCoreServices.UTType;

@interface ViewController ()

@property (nonatomic, strong) UIButton *btnOpen;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
}


- (IBAction)customAlbum:(UIButton *)sender {
    LzAlbumVC *vc = [LzAlbumVC new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.useVideoAsset = ^(PHAsset * _Nonnull asset) {
        PHVideoRequestOptions *ops = [[PHVideoRequestOptions alloc] init];
        ops.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        
        [[PHCachingImageManager defaultManager] requestAVAssetForVideo:asset options:ops resultHandler:^(AVAsset * avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset * urlAsset = (AVURLAsset *)avAsset;
            NSData * data = [NSData dataWithContentsOfURL:urlAsset.URL];
            NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            NSLog(@"base64: %@",base64);
            LzJsAsset *jsAsset = [[LzJsAsset alloc] init];
            jsAsset.base64 = base64;
            jsAsset.video = YES;
        }];
    };
    
    vc.useSelectedAssets = ^(NSArray<LzPHAsset *> * _Nonnull assets) {
        [self generateBase64FromAssets:assets];
    };
    
    [self presentViewController:vc animated:YES completion:^{

    }];
}


- (void)generateBase64FromAssets:(NSArray<LzPHAsset *>  *)assets {

    __block NSMutableArray * marr = [[NSMutableArray alloc] initWithCapacity:0];
    dispatch_queue_t queueT = dispatch_queue_create("group.queue", DISPATCH_QUEUE_CONCURRENT);//一个并发队列
    dispatch_group_t groupT = dispatch_group_create();//一个线程组
    
//    for (LzPHAsset *lz in assets) {
//
//        LzJsAsset *jsModel = [[LzJsAsset alloc] init];
//        dispatch_group_async(groupT, queueT, ^{
//            NSLog(@"group——当前线程一");
//            dispatch_group_enter(groupT);
//
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                //asset获取data，转为base64
//                [[PHCachingImageManager defaultManager] requestImageDataForAsset:lz.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//                    jsModel.base64 = base64;
//                }];
//
//                dispatch_group_leave(groupT);
//            });
//
//        });
//
//        dispatch_group_async(groupT, queueT, ^{
//            NSLog(@"group——当前线程二");
//            dispatch_group_enter(groupT);
//
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//                //获取mimeType
//                [lz.asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//                    NSString *mime = (__bridge NSString *)UTTypeCopyPreferredTagWithClass ((__bridge CFStringRef)contentEditingInput.uniformTypeIdentifier, kUTTagClassMIMEType);
//                    jsModel.mime = mime;
//                    jsModel.video = NO;
//                    [marr addObject:jsModel];
//                }];
//                dispatch_group_leave(groupT);
//            });
//
//        });
//
//    }
//
    dispatch_group_enter(groupT);
    for (LzPHAsset *lz in assets) {
        //asset获取data，转为base64
        PHImageRequestOptions *ops = [[PHImageRequestOptions alloc] init];
        ops.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        //使用线程同步
        ops.synchronous = YES;
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:lz.asset options:ops resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            LzJsAsset *jsModel = [[LzJsAsset alloc] init];
            jsModel.base64 = base64;
            [marr addObject:jsModel];
        }];
    }
    dispatch_group_leave(groupT);

    dispatch_group_notify(groupT, queueT, ^{

        NSLog(@"此时还是在子线程中");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"回到主线程");
            NSLog(@"2数量：%d", marr.count);

        });
    });
    

}


- (IBAction)takePhotoOrVideo:(UIButton *)sender {
    WXCameraController *vc = [WXCameraController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


@end
