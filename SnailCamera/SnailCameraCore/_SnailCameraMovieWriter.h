//
//  _SnailCameraMovieWriter.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/30.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "_SnailCameraCoreHelper.h"

@interface _SnailCameraMovieWriter : NSObject

kSnailCameraCorePro(CGFloat cameraMovieClarity)

- (void)prepare;
- (BOOL)isPrepared;

- (void)movieAppendBuffer:(CMSampleBufferRef)sampleBuffer Type:(AVMediaType)mediaType;

- (void)stopWithCallback:(SnailCameraMovieCallbacks)callback;

- (void)clear;

@end
