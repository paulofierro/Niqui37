//
//  ViewController.m
//  Niqui37
//
//  Created by Paulo Fierro on 18/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

#import "ViewController.h"

static NSString *birthdayString = @"18/02/2016";

@interface ViewController ()

@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) IBOutlet UILabel *days;
@property (nonatomic, strong) IBOutlet UILabel *hours;
@property (nonatomic, strong) IBOutlet UILabel *minutes;
@property (nonatomic, strong) IBOutlet UILabel *seconds;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateDate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDate) userInfo:nil repeats:YES];
}

- (void)updateDate
{
    NSDate *now = [NSDate date];
    
    if ([self.birthday earlierDate:now] == self.birthday)
    {
        // Its birthday time
        
        self.days.text      = @"";
        self.hours.text     = @"";
        self.minutes.text   = @"🎊🎂🎉";
        self.seconds.text   = @"";
    }
    else
    {
        // Its no birthday time yet, update the calendar
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:now toDate:self.birthday options:0];
        
        NSInteger days     = [dateComponents day];
        NSInteger hours    = [dateComponents hour];
        NSInteger minutes  = [dateComponents minute];
        NSInteger seconds  = [dateComponents second];
        
        self.days.text      = (days == 1) ? [NSString stringWithFormat:@"%ld day", days] : [NSString stringWithFormat:@"%ld days", days];
        self.hours.text     = (hours == 1) ? [NSString stringWithFormat:@"%ld hour", hours] : [NSString stringWithFormat:@"%ld hours", hours];
        self.minutes.text   = (minutes == 1) ? [NSString stringWithFormat:@"%ld minute", minutes] : [NSString stringWithFormat:@"%ld minutes", minutes];
        self.seconds.text   = (seconds == 1) ? [NSString stringWithFormat:@"%ld second", seconds] : [NSString stringWithFormat:@"%ld seconds", seconds];
    }
}

#pragma mark - Getters

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
        _dateFormatter.dateFormat = @"dd/MM/yyyy";
    }
    return _dateFormatter;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
