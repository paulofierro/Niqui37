//
//  AudioManager.h
//  Niqui37
//
//  Created by Paulo Fierro on 19/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

@import Foundation;

@interface AudioManager : NSObject

/// Toggles automatic navigation in the TicketViewController
/// This is a TERRIBLE place to put this
@property (nonatomic) BOOL shouldAutomaticallyNavigate;

/// Play a single firework sound effect
- (void)playFireworks;

/// Play the Happy Birthday song
- (void)playHappyBirthday;
- (void)playFlightLoop;
- (void)playHotel;
- (void)playConcert;
- (void)playNothing;
- (void)playTheater;

+ (instancetype)sharedManager;

@end
