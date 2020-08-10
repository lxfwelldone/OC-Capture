//
//  LXFCameraOperateView.h
//  CaptureView
//
//  Created by lxf2013 on 2020/1/2.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureView.h"


typedef NS_ENUM(NSUInteger, LXFCameraOperation) {
    LXFCameraOperationNone = 0,
    LXFCameraOperationTakePhoto,
    LXFCameraOperationStartRecord,
    LXFCameraOperationStopRecord,
    LXFCameraOperationStartPlay,
    LXFCameraOperationStopPlay,
    LXFCameraOperationExchange, //切换摄像头
    LXFCameraOperationBack, //返回
    LXFCameraOperationRedo, //重拍
    LXFCameraOperationUse, //使用

};

@protocol LXFCameraOperateDelegate <NSObject>

- (void)toDo:(LXFCameraOperation )operation;

- (void)toDo:(LXFCameraOperation )operation time:(NSTimeInterval)time;

@end

@interface LXFCameraOperateView : UIView

@property (nonatomic, weak) id <LXFCameraOperateDelegate> delegate;


/// 显示隐藏 保存按钮
/// @param show BOOL
- (void)showOperates:(BOOL)show;



/// 长按时隐藏
/// @param hide BOOL
- (void)hideWhenLongPress:(BOOL)hide;

@end

