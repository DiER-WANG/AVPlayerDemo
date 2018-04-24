//
//  RWPlayerLayer.m
//  AVPlayerDemo
//
//  Created by 王昌阳 on 2018/4/24.
//  Copyright © 2018年 王昌阳. All rights reserved.
//

#import "RWPlayerLayer.h"

@implementation RWPlayerLayer

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

// Override UIView method
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}


@end
