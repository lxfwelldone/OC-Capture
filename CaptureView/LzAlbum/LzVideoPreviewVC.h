//
//  LzVideoPreviewVC.h
//  CaptureView
//
//  Created by lg on 2020/8/3.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface LzVideoPreviewVC : UIViewController

@property (nonatomic, strong) PHAsset *mAsset;

@property (nonatomic, copy) void (^useVideo)(PHAsset *asset);

@end

NS_ASSUME_NONNULL_END
