//
//  ViewController.m
//  Niqui37
//
//  Created by Paulo Fierro on 18/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

@import QuartzCore;

#import "ViewController.h"

static NSString *birthdayString = @"18/02/2016 13:38";

@interface ViewController ()

@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *labelUpdateTimer;
@property (nonatomic, strong) IBOutlet UILabel *days;
@property (nonatomic, strong) IBOutlet UILabel *hours;
@property (nonatomic, strong) IBOutlet UILabel *minutes;
@property (nonatomic, strong) IBOutlet UILabel *seconds;
@property (nonatomic, strong) IBOutlet UILabel *message;
@property (nonatomic, strong) IBOutlet UIView *fireworksView;
@property (nonatomic, strong) CALayer *baseLayer;
@property (nonatomic, strong) CAEmitterLayer *emitter;
@property (nonatomic, getter=isUnlocked) BOOL unlocked;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the emitter and add it to the view
    [self.baseLayer addSublayer:self.emitter];
    [self.fireworksView.layer addSublayer:self.baseLayer];
    
    // Update the date
    [self updateDate];

    // Create the timer
    self.labelUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDate) userInfo:nil repeats:YES];
}

- (void)updateDate
{
    NSDate *now = [NSDate date];
    
    if ([self.birthday earlierDate:now] == self.birthday)
    {
        // Stop the timer
        [self.labelUpdateTimer invalidate];
        
        // Its birthday time
        self.days.text      = @"";
        self.hours.text     = @"";
        self.minutes.text   = @"🎊🎂🎉";
        self.seconds.text   = @"";
        self.message.hidden = NO;
        
        // Unlock the view
        self.unlocked = YES;
        [self animateMessage];
    }
    else
    {
        self.message.hidden = YES;
        
        // Its no birthday time yet, update the calendar
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:now toDate:self.birthday options:0];
        
        NSInteger days     = [dateComponents day];
        NSInteger hours    = [dateComponents hour];
        NSInteger minutes  = [dateComponents minute];
        NSInteger seconds  = [dateComponents second];
        
        self.days.text      = (days == 1)    ? [NSString stringWithFormat:@"%ld day", days]         : [NSString stringWithFormat:@"%ld days", days];
        self.hours.text     = (hours == 1)   ? [NSString stringWithFormat:@"%ld hour", hours]       : [NSString stringWithFormat:@"%ld hours", hours];
        self.minutes.text   = (minutes == 1) ? [NSString stringWithFormat:@"%ld minute", minutes]   : [NSString stringWithFormat:@"%ld minutes", minutes];
        self.seconds.text   = (seconds == 1) ? [NSString stringWithFormat:@"%ld second", seconds]   : [NSString stringWithFormat:@"%ld seconds", seconds];
        
        CGFloat disabledAlpha   = 0.25;
        UIColor *white          = [UIColor whiteColor];
        self.days.textColor     = (days == 0)    ? [white colorWithAlphaComponent:disabledAlpha] : white;
        self.hours.textColor    = (hours == 0)   ? [white colorWithAlphaComponent:disabledAlpha] : white;
        self.minutes.textColor  = (minutes == 0) ? [white colorWithAlphaComponent:disabledAlpha] : white;
        self.seconds.textColor  = (seconds == 0 && minutes == 0) ? [white colorWithAlphaComponent:disabledAlpha] : white;
    }
}

- (void)animateMessage
{
    // move marker up and down:
    CABasicAnimation *zoom      = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoom.toValue                = @(1.1);
    zoom.autoreverses           = YES;
    zoom.repeatCount            = INFINITY;
    zoom.timingFunction         = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    zoom.fillMode               = kCAFillModeForwards;
    [self.message.layer addAnimation:zoom forKey:@"zoomAnimation"];
}

- (void)addFireworkAtPoint:(CGPoint)point
{
    // Derived from https://github.com/tapwork/iOS-Particle-Fireworks
    UIImage *image = [UIImage imageNamed:@"firework"];
    
    CGRect bounds           = self.fireworksView.bounds;
    CGPoint maxPoint        = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    CGPoint newOriginPoint  = CGPointMake(maxPoint.x - maxPoint.x/2, maxPoint.y - maxPoint.y/2);
    CGPoint position        = CGPointMake(newOriginPoint.x + point.x, newOriginPoint.y + point.y);
    
    self.emitter.emitterPosition = position;

    // Invisible particle representing the rocket before the explosion
    CAEmitterCell *rocket       = [CAEmitterCell emitterCell];
    rocket.name                 = @"rocket"; // Name the cell so that it can be animated later using keypath
    rocket.emissionLongitude    = M_PI / 2;
    rocket.emissionLatitude     = 0;
    rocket.lifetime             = 1.6;
    rocket.birthRate            = 3;
    rocket.velocity             = 40;
    rocket.velocityRange        = 100;
    rocket.yAcceleration        = -250;
    rocket.emissionRange        = M_PI / 4;
    rocket.color                = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
    rocket.redRange             = 0.5;
    rocket.greenRange           = 0.5;
    rocket.blueRange            = 0.5;
    
    // Flare particles emitted from the rocket as it flys
    CAEmitterCell *flare    = [CAEmitterCell emitterCell];
    flare.contents          = (id)image.CGImage;
    flare.emissionLongitude = (4 * M_PI) / 2;
    flare.scale             = 0.4;
    flare.velocity          = 100;
    flare.birthRate         = 45;
    flare.lifetime          = 1.5;
    flare.yAcceleration     = -350;
    flare.emissionRange     = M_PI / 7;
    flare.alphaSpeed        = -0.7;
    flare.scaleSpeed        = -0.1;
    flare.scaleRange        = 0.1;
    flare.beginTime         = 0.01;
    flare.duration          = 0.7;
    
    // The particles that make up the explosion
    CAEmitterCell *firework = [CAEmitterCell emitterCell];
    firework.name           = @"firework";
    firework.contents       = (id)image.CGImage;
    firework.birthRate      = 9999;
    firework.scale          = 0.6;
    firework.velocity       = 130;
    firework.lifetime       = 2;
    firework.alphaSpeed     = -0.2;
    firework.yAcceleration  = -80;
    firework.beginTime      = 1.5;
    firework.duration       = 0.1;
    firework.emissionRange  = 2 * M_PI;
    firework.scaleSpeed     = -0.1;
    firework.spin           = 2;
    
    // preSpark is an invisible particle used to later emit the spark
    CAEmitterCell *preSpark = [CAEmitterCell emitterCell];
    preSpark.name           = @"preSpark";
    preSpark.birthRate      = 80;
    preSpark.velocity       = firework.velocity * 0.70;
    preSpark.lifetime       = 1.7;
    preSpark.yAcceleration  = firework.yAcceleration * 0.85;
    preSpark.beginTime      = firework.beginTime - 0.2;
    preSpark.emissionRange  = firework.emissionRange;
    preSpark.greenSpeed     = 100;
    preSpark.blueSpeed      = 100;
    preSpark.redSpeed       = 100;
    
    // The 'sparkle' at the end of a firework
    CAEmitterCell *spark    = [CAEmitterCell emitterCell];
    spark.contents          = (id)image.CGImage;
    spark.lifetime          = 0.05;
    spark.yAcceleration     = -250;
    spark.beginTime         = 0.8;
    spark.scale             = 0.4;
    spark.birthRate         = 10;
    
    preSpark.emitterCells       = @[spark];
    rocket.emitterCells         = @[flare, firework, preSpark];
    self.emitter.emitterCells   = @[rocket];
    
    [self.fireworksView setNeedsDisplay];
- (void)removeFireworks
{
    [self.emitter setValue:@(0) forKeyPath:@"emitterCells.rocket.lifetime"];
    [self.emitter setValue:@(0) forKeyPath:@"emitterCells.rocket.emitterCells.firework.lifetime"];
    [self.emitter setValue:@(0) forKeyPath:@"emitterCells.rocket.emitterCells.preSpark.lifetime"];
}

#pragma mark - Getters

- (CAEmitterLayer *)emitter
{
    if (_emitter == nil)
    {
        _emitter = [CAEmitterLayer layer];
        _emitter.renderMode = kCAEmitterLayerBackToFront;
        _emitter.lifetime = 1;
    }
    return _emitter;
}

- (CALayer *)baseLayer
{
    if (_baseLayer == nil)
    {
        _baseLayer = [CALayer layer];
        _baseLayer.bounds = self.fireworksView.bounds;
        _baseLayer.backgroundColor = self.fireworksView.backgroundColor.CGColor;
    }
    return _baseLayer;
}

- (NSDate *)birthday
{
    if (_birthday == nil)
    {
        _birthday = [self.dateFormatter dateFromString:birthdayString];
    }
    return _birthday;
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
    }
    return _dateFormatter;
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.isUnlocked)
    {
        UITouch *touch = touches.allObjects.firstObject;
        [self addFireworkAtPoint:[touch locationInView:self.fireworksView]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
