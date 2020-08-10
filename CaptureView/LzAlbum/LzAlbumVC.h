//
//  ViewController.h
//  CaptureView
//
//  Created by lg on 2020/7/30.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LzAlbumCC.h"
#import "LzVideoPreviewVC.h"
#import "LzImagePreviewVC.h"
#import "LzPHAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface LzAlbumVC : UIViewController

@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, copy) void(^useSelectedAssets)(NSArray<LzPHAsset *> *assets);
@property (nonatomic, copy) void(^useVideoAsset)(PHAsset *asset);


@end

NS_ASSUME_NONNULL_END
