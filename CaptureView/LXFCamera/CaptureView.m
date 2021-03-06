//
//  CaptureView.m
//  CaptureView
//
//  Created by lxf2013 on 2019/12/30.
//  Copyright © 2019 lxf. All rights reserved.
//

#import "CaptureView.h"

@interface CaptureView()

@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) CGRect circleFrame;
@property (nonatomic, assign) BOOL isCancle;
@property (nonatomic, assign) BOOL isTimeout;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval tempInterval;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *centerLayer;   // 中间圈圈
@property (nonatomic, strong) CAShapeLayer *circleLayer;   // 周围透明部分
@property (nonatomic, strong) CAShapeLayer *progressLayer; // 进度条

@end

@implementation CaptureView



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}

- (void)configure {
//    self.backgroundColor = [UIColor clearColor];
    
    _isPressed = NO;
    _isCancle = NO;
    _isTimeout = NO;
    _tempInterval = 0;
    _progress = 0.0;
    _interval = 10;
    _centerLayerColor = [UIColor whiteColor];
    _circleLayerColor = [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:0.4];
    _progressLayerColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1.0];
    _progressLayerWidth = 4;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            [self link];
            _isPressed = YES;
            if (self.stateBlock) {
                self.stateBlock(CaptureViewStateLongPressBegan, 0);
            }
        }
        break;

        case UIGestureRecognizerStateEnded:
            if (self.stateBlock) {
                self.stateBlock(CaptureViewStateLongPressEnd, _tempInterval);
            }
            _isTimeout = NO;
            [self stop];
            [self setNeedsDisplay];
            break;
        default:
            break;
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.stateBlock) {
        self.stateBlock(CaptureViewStateClick, 0);
    }
}



- (void)beginRun:(CADisplayLink *)link {
    _tempInterval += 1 / 60.0;
    _progress = _tempInterval / _interval;
    if (_tempInterval >= _interval) {
        _isTimeout = YES;
        if (self.stateBlock) {
            self.stateBlock(CaptureViewStateLongPressEnd, _interval);
        }
        [self stop];
    }
    [self setNeedsDisplay];
}

- (void)stop {
    [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_link invalidate];
    _link = nil;
    
    _isPressed = NO;
    _isCancle = NO;
    _tempInterval = 0;
    _progress = 0;
    
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;
}

- (void)drawRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat mainWidth = width;
    CGRect mainFrame = CGRectMake(0, 0, mainWidth, mainWidth);
    CGRect circleFrame = CGRectInset(mainFrame, -0.4*mainWidth/2.0, -0.4*mainWidth/2.0);
    if (_isPressed) {
        circleFrame = CGRectInset(mainFrame, -1.2*mainWidth/2.0, -1.2*mainWidth/2.0);
    }
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:circleFrame cornerRadius:CGRectGetWidth(circleFrame)/2.0];
    self.circleLayer.path = circlePath.CGPath;
  
    if (_isPressed) {
        mainWidth *= 0.6;
        mainFrame = CGRectMake((width - mainWidth)/2.0, (width - mainWidth)/2.0, mainWidth, mainWidth);
    }
    UIBezierPath *mainPath = [UIBezierPath bezierPathWithRoundedRect:mainFrame cornerRadius:mainWidth/2.0];
    self.centerLayer.path = mainPath.CGPath;
    
    if (_isPressed) {
        CGRect progressFrame = CGRectInset(circleFrame, 2.0, 2.0);
        UIBezierPath *progressPath = [UIBezierPath bezierPathWithRoundedRect:progressFrame cornerRadius:CGRectGetWidth(progressFrame)/2.0];
        self.progressLayer.path = progressPath.CGPath;
        self.progressLayer.strokeEnd = _progress;
        _circleFrame = progressFrame;
        
    }
    
}

- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(beginRun:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _link;
}

- (CAShapeLayer *)centerLayer {
    if (!_centerLayer) {
        _centerLayer = [CAShapeLayer layer];
        _centerLayer.frame = self.bounds;
        _centerLayer.fillColor = _centerLayerColor.CGColor;
        [self.layer addSublayer:_centerLayer];
    }
    return _centerLayer;
}

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = self.bounds;
        _circleLayer.fillColor = _circleLayerColor.CGColor;
        [self.layer addSublayer:_circleLayer];
    }
    return _circleLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = _progressLayerColor.CGColor;
        _progressLayer.lineWidth = _progressLayerWidth;
        _progressLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

@end
