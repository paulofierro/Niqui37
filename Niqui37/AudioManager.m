//
//  AudioManager.m
//  Niqui37
//
//  Created by Paulo Fierro on 19/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//
@import AVFoundation;

#import "AudioManager.h"

@interface AudioManager ()

@property (nonatomic) SystemSoundID fireworksID;
@property (nonatomic) AVQueuePlayer *queuePlayer;

@end

@implementation AudioManager

- (void)playHappyBirthday
{
    AVPlayerItem *item = [self playerForLoop:@"Happy Birthday"];
    [self addItemToQueue:item];
}

- (void)playFlightLoop
{
    AVPlayerItem *item = [self playerForLoop:@"Take-Off"];
    [self addItemToQueue:item];
}

- (void)playHotel
{
    AVPlayerItem *item = [self playerForLoop:@"Hotel"];
    [self addItemToQueue:item];
}

- (void)playConcert
{
    AVPlayerItem *item = [self playerForLoop:@"Goldfish"];
    [self addItemToQueue:item];
}

- (void)playNothing
{
    AVPlayerItem *item = [self playerForLoop:@"Nothing"];
    [self addItemToQueue:item];
}

- (void)playTheater
{
    AVPlayerItem *item = [self playerForLoop:@"Book-Of-Mormon"];
    [self addItemToQueue:item];
}

- (void)addItemToQueue:(AVPlayerItem *)item
{
    if (self.queuePlayer == nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        self.queuePlayer = [[AVQueuePlayer alloc] initWithPlayerItem:item];
        self.queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self.queuePlayer play];
    }
    else
    {
        BOOL canInsert = [self.queuePlayer canInsertItem:item afterItem:self.queuePlayer.currentItem];
        if (canInsert)
        {
            [self.queuePlayer insertItem:item afterItem:self.queuePlayer.currentItem];
            if (self.queuePlayer.items.count > 1)
            {
                [self.queuePlayer advanceToNextItem];
            }
            else
            {
                [self.queuePlayer play];
            }
        }
    }
}

/// Loop the current item when it reaches the end
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *item = self.queuePlayer.currentItem;
    [item seekToTime:kCMTimeZero];
    [self.queuePlayer play];
}

#pragma mark - Helper Methods

- (AVPlayerItem *)playerForLoop:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager new];
    NSString *path  = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:path])
    {
        NSURL *pathURL      = [NSURL fileURLWithPath:path];
        AVPlayerItem *item  = [AVPlayerItem playerItemWithURL:pathURL];
        return item;
    }
    else
    {
        DLog(@"File does not exist %@", path);
    }
    return nil;
}


#pragma mark - Play FX

- (void)playFireworks
{
    [self playSound:@"single_firework" extension:@"caf" soundID:self.fireworksID];
}

- (void)playSound:(NSString *)filename extension:(NSString *)extension soundID:(SystemSoundID)soundID
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSError *error = nil;
        // Ignore the MUTE switch and default to speaker
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
        if (error)
        {
            DLog(@"[ERROR] Could not override output audio port: %@", error.localizedDescription);
        }
    });
    
    NSFileManager *fileManager = [NSFileManager new];
    NSString *path  = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    if (!soundID && [fileManager fileExistsAtPath:path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(pathURL), &soundID);
    }
    if (soundID)
    {
        AudioServicesPlaySystemSound(soundID);
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Turn this on by default
        self.shouldAutomaticallyNavigate = YES;
    }
    return self;
}

#pragma mark - Static Methods

+ (instancetype)sharedManager;
{
    static AudioManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

@end
