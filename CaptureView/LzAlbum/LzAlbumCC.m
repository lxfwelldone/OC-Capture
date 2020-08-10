//
//  LzAlbumCC.m
//  CaptureView
//
//  Created by lg on 2020/7/31.
//  Copyright © 2020 lxf. All rights reserved.
//

#import "LzAlbumCC.h"

@implementation LzAlbumCC

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (NSString *)duration2Str:(NSTimeInterval )ti {
    NSString * str;
    NSInteger t = round(ti);
    if (t < 10 && t > 0) {
        str = [NSString stringWithFormat:@"时长 00:0%ld", t];
    } else if (t >= 10 && t < 60) {
        str = [NSString stringWithFormat:@"时长 00:%ld", t];
    } else if (t >= 60 && t < 600) {
        NSInteger m = t / 60;
        NSInteger s = t % 60;
        if (s >= 10) {
            str = [NSString stringWithFormat:@"时长 0%ld:%ld", m, s];
        } else {
            str = [NSString stringWithFormat:@"时长 0%ld:0%ld", m, s];
        }
    } else if (t >= 600 && t < 3600 ) {
        NSInteger m = t / 60;
        NSInteger s = t % 60;
        if (s >= 10) {
            str = [NSString stringWithFormat:@"时长 %ld:%ld", m, s];
        } else {
            str = [NSString stringWithFormat:@"时长 %ld:0%ld", m, s];
        }
    }
    return str;
}



- (void)displayAsset:(LzPHAsset *)a selectBlock:(nonnull SelectBlock)selectBlock{
    self.selectBlock = selectBlock;
    self.mAsset = a;
    if (a.asset.mediaType == PHAssetMediaTypeVideo) {
        self.lblDuration.hidden = NO;
        self.lblDuration.text = [self duration2Str:a.asset.duration];
        self.imgSelect.hidden = YES;
    } else {
        self.imgSelect.hidden = NO;
        self.lblDuration.hidden = YES;
        if (a.select) {
            self.imgSelect.image = [UIImage imageNamed:@"check_true"];
        }else {
            self.imgSelect.image = [UIImage imageNamed:@"check_false"];
        }
    }

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    __weak typeof(self) weakSelf = self;
    NSInteger retinaScale = [UIScreen mainScreen].scale;
      CGSize retinaSquare = CGSizeMake(self.frame.size.width*retinaScale, self.frame.size.height*retinaScale);
    [[PHCachingImageManager defaultManager] requestImageForAsset:a.asset targetSize:retinaSquare contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.imgShow.image = result;
    }];
}

- (void)addViews {
    [self.contentView addSubview:self.imgShow];
    [self.contentView addSubview:self.imgSelect];
    [self.contentView addSubview:self.lblDuration];
    
    self.imgShow.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imgSelect.frame = CGRectMake(self.frame.size.width - 30, 6, 24, 24);
    self.lblDuration.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30);
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnSelect)];
    [self.imgSelect addGestureRecognizer:tap];
}
    
- (void)clickOnSelect {
    if (self.selectBlock) {
        self.selectBlock(self.mAsset);
    }
}
    
    
- (UILabel *)lblDuration {
    if (!_lblDuration) {
        _lblDuration = [[UILabel alloc] init];
        _lblDuration.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _lblDuration.textColor = UIColor.whiteColor;
        _lblDuration.textAlignment = NSTextAlignmentCenter;
        _lblDuration.font = [UIFont systemFontOfSize:13];
        _lblDuration.text = @"时长:";
    }
    return _lblDuration;
}

- (UIImageView *)imgShow {
    if (!_imgShow) {
        _imgShow = [[UIImageView alloc] init];
        _imgShow.contentMode = UIViewContentModeCenter;
        _imgShow.layer.masksToBounds = YES;
    }
    return _imgShow;
}


- (UIImageView *)imgSelect {
    if (!_imgSelect) {
        _imgSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_false"]];
        _imgSelect.contentMode = UIViewContentModeScaleAspectFit;
        _imgSelect.userInteractionEnabled = YES;
    }
    return _imgSelect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
