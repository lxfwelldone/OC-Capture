//
//  LXFCameraOperateView.m
//  CaptureView
//
//  Created by lxf2013 on 2020/1/2.
//  Copyright © 2020 lxf. All rights reserved.
//

#import "LXFCameraOperateView.h"

@interface LXFCameraOperateView()<UIGestureRecognizerDelegate>


/// 返回
@property (nonatomic, strong) UIButton *btnDown;
/// 重拍
@property (nonatomic, strong) UIButton *btnRedo;
/// 使用
@property (nonatomic, strong) UIButton *btnUse;
/// 切换摄像头
@property (nonatomic, strong) UIButton *btnExchange;


@property (nonatomic, strong) CaptureView *capView;

@end





@implementation LXFCameraOperateView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addViews];
    
    }
    return self;
}


- (void)addViews{
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    

    
    __weak typeof(self) weakSelf = self;
    self.capView.stateBlock = ^(CaptureViewState state, NSTimeInterval t) {
        LXFCameraOperation op = LXFCameraOperationNone;
        if (state == CaptureViewStateClick) {
            [weakSelf showOperates:YES];
            op = LXFCameraOperationTakePhoto;
        } else if (state == CaptureViewStateLongPressBegan){
            op = LXFCameraOperationStartRecord;
            [weakSelf hideWhenLongPress:YES];
        } else if (state == CaptureViewStateLongPressEnd){
            op = LXFCameraOperationStopRecord;
            [weakSelf hideWhenLongPress:NO];
        }
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(toDo:time:)]){
            [weakSelf.delegate toDo:op time:t];
        }
    };
    _capView.center = CGPointMake(self.center.x, h - 100);
    

    
    self.btnExchange.center = CGPointMake(w-50, 100);
    self.btnDown.center = CGPointMake(CGRectGetMinX(_capView.frame) - 60, CGRectGetMidY(_capView.frame));
    self.btnRedo.center = CGPointMake(CGRectGetMinX(_capView.frame) - 60, CGRectGetMidY(_capView.frame));
    self.btnUse.center = CGPointMake(CGRectGetMaxX(_capView.frame) + 60, CGRectGetMidY(_capView.frame));

    
    [self addSubview:self.capView];
    

    [self addSubview:self.btnExchange];
    [self addSubview:self.btnDown];
    [self addSubview:self.btnRedo];
    [self addSubview:self.btnUse];
    
    
    [self showOperates:NO];
    
}

- (void)clickOnBtns:(UIButton *)btn{
    if (self.delegate && [self.delegate performSelector:@selector(toDo:)]) {
        if (btn == self.btnExchange) {
            NSLog(@"btnExchange");
            [self.delegate toDo:LXFCameraOperationExchange];
            
        } else if (btn == self.btnDown) {
            NSLog(@"btnDown");
            [self.delegate toDo:LXFCameraOperationBack];

        } else if (btn == self.btnRedo) {
            NSLog(@"btnRedo");
            [self showOperates:NO];
            [self.delegate toDo:LXFCameraOperationRedo];

        } else if (btn == self.btnUse) {
            NSLog(@"btnUse");
            //保存并使用
            [self.delegate toDo:LXFCameraOperationUse];

        }
    } else {
        NSLog(@"请设置delegate");
    }

}



/// 显示隐藏 保存按钮
/// @param show BOOL
- (void)showOperates:(BOOL)show{
    self.btnExchange.hidden = show;
    self.btnDown.hidden = show;
    self.btnRedo.hidden = !show;
    self.btnUse.hidden = !show;

    self.capView.hidden = show;

}


/// 长按时隐藏
/// @param hide BOOL
- (void)hideWhenLongPress:(BOOL)hide{
    self.btnExchange.hidden = hide;
    self.btnDown.hidden = hide;
}




#pragma mark - 懒加载
- (CaptureView *)capView{
    if (!_capView) {
        _capView = [[CaptureView alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    }
    return _capView;
}


- (UIButton *)btnUse{
    if (!_btnUse) {
        _btnUse = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnUse setBackgroundImage:[UIImage imageNamed:@"camera_use"] forState:UIControlStateNormal];
        _btnUse.frame =  CGRectMake(0, 0, 60, 60);
        [_btnUse addTarget:self action:@selector(clickOnBtns:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnUse;
}

- (UIButton *)btnRedo{
    if (!_btnRedo) {
        _btnRedo = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnRedo setImage:[UIImage imageNamed:@"camera_redo"] forState:UIControlStateNormal];
        _btnRedo.frame =  CGRectMake(0, 0, 60, 60);
        [_btnRedo addTarget:self action:@selector(clickOnBtns:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRedo;
}


- (UIButton *)btnDown{
    if (!_btnDown) {
        _btnDown = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnDown setBackgroundImage:[UIImage imageNamed:@"arrow_white_down"] forState:UIControlStateNormal];
        _btnDown.frame =  CGRectMake(0, 0, 60, 60);
        [_btnDown addTarget:self action:@selector(clickOnBtns:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDown;
}



- (UIButton *)btnExchange{
    if (!_btnExchange) {
        _btnExchange = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnExchange setBackgroundImage:[UIImage imageNamed:@"camera_exchange"] forState:UIControlStateNormal];
        _btnExchange.frame =  CGRectMake(0, 0, 60, 60);
        [_btnExchange addTarget:self action:@selector(clickOnBtns:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnExchange;
}



@end
