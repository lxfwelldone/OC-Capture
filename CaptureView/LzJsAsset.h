//
//  LzJsAsset.h
//  CaptureView
//
//  Created by lg on 2020/8/5.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LzJsAsset : NSObject

@property (nonatomic, strong) NSString *mime;
@property (nonatomic, strong) NSString *base64;
@property (nonatomic, assign) BOOL video;


@end

NS_ASSUME_NONNULL_END
