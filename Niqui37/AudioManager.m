//
//  AudioManager.m
//  Niqui37
//
//  Created by Paulo Fierro on 19/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//
@import AVFoundation;

#import "AudioManager.h"

@implementation AudioManager


+ (void)playFireworks
{
    static SystemSoundID fireworksID;
    [[self class] playSound:@"single_firework" extension:@"caf" soundID:fireworksID];
}

+ (void)playSound:(NSString *)filename extension:(NSString *)extension soundID:(SystemSoundID)soundID
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
