//
//  RWPlayerLayer.h
//  AVPlayerDemo
//
//  Created by 王昌阳 on 2018/4/24.
//  Copyright © 2018年 王昌阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RWPlayerLayer : UIView

@property AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSString *videoFillMode;
@end
