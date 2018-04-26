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



static void *ItemStatusContext = &ItemStatusContext;
static void *PlayerCurrentItemContext = &PlayerCurrentItemContext;
static void *PlayerRateContext = &PlayerRateContext;

@interface AVPlayerDemoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgressView;
@property (weak, nonatomic) IBOutlet UISlider *timeSliderView;
@property (weak, nonatomic) IBOutlet UISlider *volumeSliderView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (weak, nonatomic) IBOutlet RWPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, assign) BOOL seekToZeroBeforePlay;// 如果已经播放结束，下次播放时，从头开始播放
@property (nonatomic, assign) CGFloat rateBeforeScrub;// 滑动之前的播放状态

@property (nonatomic, strong) id playerTimeObserver;

@end

@implementation AVPlayerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _player = nil;
}

- (void)dealloc {
    
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playBtnClicked:(UIButton *)sender {
    if (sender.isSelected) {
        [_player pause];
    } else {
        [_player play];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setUrl:(NSURL *)url {
    if (_url != url) {
        _url = url;
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_url options:nil];
        NSArray *requestKeys = @[@"playable"];
        [asset loadValuesAsynchronouslyForKeys:requestKeys completionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self preparePlay:asset keys:requestKeys];
            });
        }];
    }
}

- (void)preparePlay:(AVURLAsset *)asset keys:(NSArray *)keys {
    for (NSString *thisKey in keys) {
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:thisKey error:&error];
        if (status == AVKeyValueStatusFailed) {
            // 准备播放失败
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
    }
    
    if (!asset.playable) {
        // 不能播放
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        return;
    }
    
    if (_item) {
        [_item removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
    }
    _item = [AVPlayerItem playerItemWithAsset:asset];
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
    _seekToZeroBeforePlay = NO;
    
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:_item];
        _playerLayer.player = _player;
        [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayerCurrentItemContext];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:PlayerRateContext];
    }
    
    if (_player.currentItem != _item) {
        [_player replaceCurrentItemWithPlayerItem:_item];
        [self syncPlayerBtnState];
    }
    self.timeSliderView.value = 0.f;
}


#pragma mark - AVPlayerItemKVO
- (void)playerItemDidPlayToEnd:(NSNotification *)notify {
    _seekToZeroBeforePlay = YES;
}

- (BOOL)isPlaying {
    return _rateBeforeScrub != 0.f || _player.rate != 0.f;
}

- (void)syncPlayerBtnState {
    self.playBtn.selected = [self isPlaying];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ItemStatusContext) {
        [self syncPlayerBtnState];
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown: {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self disableScrubber];
                [self disablePlayerBtns];
            } break;
            case AVPlayerItemStatusFailed: {
                AVPlayerItem *item = [_player currentItem];
                [self assetFailedToPrepareForPlayback:item.error];
            } break;
            case AVPlayerItemStatusReadyToPlay: {
                [self initScrubberTimer];
                [self enableScrubber];
                [self enablePlayerBtns];
            } break;
                
            default:
                break;
        }
    } else if (context == PlayerRateContext) {
        [self syncPlayerBtnState];
    } else if (context == PlayerCurrentItemContext) {
        AVPlayerItem *newItem = [change objectForKey:NSKeyValueChangeNewKey];
        if (newItem == (id)[NSNull null]) {
            [self disablePlayerBtns];
            [self disableScrubber];
        } else {
            _playerLayer.player = _player;
            [self setViewDisplayName];
            [_playerLayer setVideoFillMode:AVLayerVideoGravityResizeAspect];
            [self syncPlayerBtnState];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - AVPlayerItemStatusUnknown Method
- (void)removePlayerTimeObserver {
    if (_playerTimeObserver) {
        [_player removeTimeObserver:_playerTimeObserver];
        _playerTimeObserver = nil;
    }
}

- (void)syncScrubber {
    CMTime duration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(duration)) {
        _timeSliderView.minimumValue = 0.0;
        return;
    }
    double seconds = CMTimeGetSeconds(duration);
    if (isfinite(seconds)) {
        float minValue = _timeSliderView.minimumValue;
        float maxValue = _timeSliderView.maximumValue;
        double time = CMTimeGetSeconds(_player.currentTime);
        _timeSliderView.value = (maxValue - minValue) * time / seconds + minValue;
    }
}
#pragma mark - AVPlayerItemStatusReadyToPlay Method
- (void)initScrubberTimer {
    double interval = .1f;
    
    CMTime duration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(duration)) {
        return;
    }
    double seconds = CMTimeGetSeconds(duration);
    if (isfinite(seconds)) {
        CGFloat width = CGRectGetWidth([_timeSliderView bounds]);
        interval = 0.5f * seconds / width;
    }
    __weak AVPlayerDemoViewController *weakSelf = self;
    _playerTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf syncScrubber];
    }];
}

- (void)disableScrubber {
    _timeSliderView.enabled = NO;
}

- (void)enableScrubber {
    _timeSliderView.enabled = YES;
}

- (void)disablePlayerBtns {
    _playBtn.enabled = NO;
}

- (void)enablePlayerBtns {
    _playBtn.enabled = YES;
}

- (void)assetFailedToPrepareForPlayback:(NSError *)error {
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerBtns];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (CMTime)playerItemDuration {
    AVPlayerItem *item = [_player currentItem];
    if (item.status == AVPlayerItemStatusReadyToPlay) {
        return [item duration];
    }
    return kCMTimeInvalid;
}

- (void)setViewDisplayName {
    self.title = [_url lastPathComponent];
    for (AVMetadataItem *metaItem in _player.currentItem.asset.commonMetadata) {
        NSString *commonKey = [metaItem commonKey];
        if ([commonKey isEqualToString:AVMetadataCommonKeyTitle])
        {
            self.title = [metaItem stringValue];
        }
    }
}

@end
