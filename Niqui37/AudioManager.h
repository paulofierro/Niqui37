//
//  AudioManager.h
//  Niqui37
//
//  Created by Paulo Fierro on 19/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

@import Foundation;

@interface AudioManager : NSObject

/// Play a single firework sound effect
+ (void)playFireworks;

+ (instancetype)sharedManager;

@end
