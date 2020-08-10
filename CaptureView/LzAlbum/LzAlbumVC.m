//
//  ViewController.m
//  CaptureView
//
//  Created by lg on 2020/7/30.
//  Copyright © 2020 lxf. All rights reserved.
//

#import "LzAlbumVC.h"


@interface LzAlbumVC ()<UICollectionViewDelegate, UICollectionViewDataSource>


@property (nonatomic, strong) NSMutableArray * marrDatas;
@property (weak, nonatomic) IBOutlet UICollectionView *mCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnComplete;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCompleteW;
@property (nonatomic, strong) NSMutableArray *marrSelected;
@end


@implementation LzAlbumVC
- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)complete:(UIButton *)sender {
    
    if (self.marrSelected.count > 0) {
        if (self.useSelectedAssets) {
            self.useSelectedAssets(self.marrSelected);
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initValues];
    
    [self addViews];

    [self loadData];

}

- (void)initValues {
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.marrDatas = [[NSMutableArray alloc] initWithCapacity:0];
    self.marrSelected = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (self.maxCount <=0) {
        self.maxCount = 9;
    }
}

- (void)loadData {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ) {
        //没有权限，打开权限后再来操作
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self loadAsset];
    } else if (status == PHAuthorizationStatusNotDetermined ) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status2) {
            if(status2 == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 用户点击 "OK"
                    [self loadAsset];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 用户点击 不允许访问
                    [self dismissViewControllerAnimated:NO completion:nil];
                });
            }
        }];
    } else {
        //用户拒绝, 告诉他去设置允许
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"缺少读写相册权限" message:@"立即去设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * actionDone = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            if ([[UIApplication sharedApplication] canOpenURL:url]) {
//                [[UIApplication sharedApplication] openURL:url];
//            }
        }];
        
        UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];

        [alertVC addAction:actionDone];
        [alertVC addAction:actionCancel];
        alertVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:alertVC animated:YES completion:nil];
    }

}


- (void)loadAsset {
    //有权限
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSSortDescriptor *sortDate = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    options.sortDescriptors = [NSArray arrayWithObject:sortDate];

    PHFetchResult<PHAsset *>* sserts = [PHAsset fetchAssetsWithOptions:options];
    [sserts enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        LzPHAsset * lzAsset = [[LzPHAsset alloc] init];
        lzAsset.select = NO;
        lzAsset.asset = asset;
        [self.marrDatas addObject:lzAsset];
            
    }];
    
//        PHFetchResult<PHAssetCollection *> *acUserLib = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options];
    

//        [acUserLib enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull assetC, NSUInteger idx, BOOL * _Nonnull stop) {
//
//            PHFetchResult<PHAsset *> * resAssets = [PHAsset fetchAssetsInAssetCollection:assetC options:nil];
//            __block int imgCount = 0;
//            __block int videoCount = 0;
//            [resAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
//                LzPHAsset * lzAsset = [[LzPHAsset alloc] init];
//                lzAsset.select = NO;
//                lzAsset.asset = asset;
//                [self.marrDatas addObject:lzAsset];
//
//            }];
//
//        }];
    
    
    [self.mCollectionView reloadData];
        
}

- (void)addViews {
    
    UICollectionViewFlowLayout *flowLaout = [[UICollectionViewFlowLayout alloc]init];
    flowLaout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //上下间距
    flowLaout.minimumLineSpacing = 0;
    //左右间距
    flowLaout.minimumInteritemSpacing = 0;

    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    flowLaout.itemSize = CGSizeMake(w/4.0, w/4.0);
    self.mCollectionView.collectionViewLayout = flowLaout;
    self.mCollectionView.backgroundColor = UIColor.whiteColor;
    [self.mCollectionView registerClass:[LzAlbumCC class] forCellWithReuseIdentifier:@"LzAlbumCCID"];
    
}


- (void)displayCompletion {
    NSString * str = @"完成";
    if (self.marrSelected.count > 0) {
        str = [NSString stringWithFormat:@"完成(%d/%d)", self.marrSelected.count, self.maxCount];
        [self.btnComplete setBackgroundColor:UIColor.blueColor];
        self.btnCompleteW.constant = 75;
    } else {
        [self.btnComplete setBackgroundColor:UIColor.grayColor];
        self.btnCompleteW.constant = 50;
    }
    [self.btnComplete setTitle:str forState:UIControlStateNormal];
    
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.marrDatas.count;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LzAlbumCC *cc =  [self.mCollectionView dequeueReusableCellWithReuseIdentifier:@"LzAlbumCCID" forIndexPath:indexPath];
    LzPHAsset * m = [self.marrDatas objectAtIndex:indexPath.row];

    [cc displayAsset:m selectBlock:^(LzPHAsset * asset) {
        if (self.marrSelected.count >= self.maxCount) {
            NSLog(@"最多只能选择 %ld 个", self.maxCount);
            return;
        }
        m.select = !m.select;
        [self.mCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        if (m.select) {
            [self.marrSelected addObject:asset];
        } else {
            [self.marrSelected removeObject:asset];
        }
        [self displayCompletion];
    }];
    return cc;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    LzPHAsset * a = [self.marrDatas objectAtIndex:indexPath.row];
    if (a.asset.mediaType == PHAssetMediaTypeVideo) {
        
        if (self.marrSelected.count > 0) {
            NSLog(@"不能同时选择图片和视频哦");
            return;
        }
        
        //视频
        LzVideoPreviewVC * vc = [[LzVideoPreviewVC alloc] init];
        vc.mAsset = a.asset;
        vc.useVideo = ^(PHAsset * _Nonnull asset) {
            if (self.useVideoAsset) {
                self.useVideoAsset(asset);
            }
        };
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        //图片
        LzImagePreviewVC * vc = [[LzImagePreviewVC alloc] init];
        vc.mAsset = a.asset;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}


@end
