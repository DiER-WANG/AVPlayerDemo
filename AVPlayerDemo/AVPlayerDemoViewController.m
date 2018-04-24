//
//  AVPlayerDemoViewController.m
//  AVPlayerDemo
//
//  Created by 王昌阳 on 2018/4/24.
//  Copyright © 2018年 王昌阳. All rights reserved.
//

#import "AVPlayerDemoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RWPlayerLayer.h"

@interface AVPlayerDemoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation AVPlayerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"demo_01" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    _player = [[AVPlayer alloc] initWithPlayerItem:item];
    RWPlayerLayer *layer = [[RWPlayerLayer alloc] initWithFrame:self.view.bounds];
    layer.player = _player;
    [self.view addSubview:layer];
    [_player play];
    [self.view bringSubviewToFront:_backBtn];
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
