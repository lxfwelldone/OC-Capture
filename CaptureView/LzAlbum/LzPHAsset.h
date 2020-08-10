//
//  LzPHAsset.h
//  CaptureView
//
//  Created by lg on 2020/8/3.
//  Copyright © 2020 lxf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LzPHAsset : NSObject

@property(nonatomic, assign) BOOL select;

@property(nonatomic, strong) PHAsset *asset;

@end
