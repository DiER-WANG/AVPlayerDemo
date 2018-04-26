//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by 王昌阳 on 2018/4/23.
//  Copyright © 2018年 王昌阳. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVPlayerViewController.h>
#import "AVPlayerDemoViewController.h"

@interface ViewController ()

@property (nonatomic, assign) NSUInteger playIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPlayerVC:(id)sender {
    NSURL *fileURL = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:(_playIndex % 2 == 0 ? @"demo_00" : @"demo_01") ofType:@"mp4"];
    switch (_playIndex%3) {
        case 0: {
            fileURL = [NSURL fileURLWithPath:path];
        } break;
        case 1: {
            fileURL = [NSURL fileURLWithPath:path];
        } break;
        case 2: {
            fileURL = [NSURL URLWithString:@"https://devstreaming-cdn.apple.com/videos/tutorials/20170912/502bbcn7dmn9r/an_introduction_to_hdr_video/hls_vod_mvp.m3u8"];
        } break;
            
        default:
            break;
    }
    _playIndex++;
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    AVPlayerItem *item = [[AVPlayerItem  alloc] initWithAsset:asset];
    
    AVPlayer *avplayer = [[AVPlayer alloc] initWithPlayerItem:item];
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = avplayer;
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[AVPlayerDemoViewController class]]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:(_playIndex % 2 == 0 ? @"demo_00" : @"demo_01") ofType:@"mp4"];
        NSLog(@"%@", path);
        AVPlayerDemoViewController *demoVC = segue.destinationViewController;
        demoVC.url = [NSURL URLWithString:@"https://devstreaming-cdn.apple.com/videos/tutorials/20170912/502bbcn7dmn9r/an_introduction_to_hdr_video/hls_vod_mvp.m3u8"];//[NSURL fileURLWithPath:path];
    }
}


@end
