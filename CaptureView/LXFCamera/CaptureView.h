//
//  CaptureView.h
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, CaptureViewState) {
    CaptureViewStateNormal = 0,
    CaptureViewStateLongPressBegan, // 开始长按
    CaptureViewStateLongPressEnd,     // 长按结束
    CaptureViewStateClick       // 点击
};




@interface CaptureView : UIView


@property (nonatomic, copy) void (^stateBlock)(CaptureViewState state, NSTimeInterval t);


/**
 进度条走完一圈所用时间（默认10s）
 */
@property (nonatomic, assign) NSTimeInterval interval;

/**
 中间圈圈颜色（默认白色）
 */
@property (nonatomic) UIColor *centerLayerColor;

/**
 周围透明区域颜色（默认白色透明度0.6）
 */
@property (nonatomic) UIColor *circleLayerColor;

/**
 进度条颜色（默认绿色）
 */
@property (nonatomic) UIColor *progressLayerColor;

/**
 进度条宽度（默认4）
 */
@property (nonatomic, assign) CGFloat progressLayerWidth;


@end

