//
//  LzAlbumCC.h
//  CaptureView
//
//  Created by lg on 2020/7/31.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LzPHAsset.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectBlock)(LzPHAsset *asset);

@interface LzAlbumCC : UICollectionViewCell


@property (nonatomic, strong) UIImageView *imgShow;
@property (nonatomic, strong) UIImageView *imgSelect;
@property (nonatomic, strong) UILabel *lblDuration;
@property (nonatomic, copy) SelectBlock selectBlock;
@property (nonatomic, strong) LzPHAsset *mAsset;

- (void)displayAsset:(LzPHAsset *)a selectBlock:(SelectBlock)selectBlock;

@end

NS_ASSUME_NONNULL_END
