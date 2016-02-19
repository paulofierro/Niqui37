//
//  TicketViewController.m
//  Niqui37
//
//  Created by Paulo Fierro on 18/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

#import "TicketViewController.h"
#import "AudioManager.h"

typedef NS_ENUM(NSInteger, Page) {
    PageFlightToNY = 0,
    PageHotel = 1,
    PageConcert = 2,
    PageNothing = 3,
    PageTheater = 4,
    PageFlightToGCM = 5,
};

@interface TicketViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizer;

@end

@implementation TicketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.swipeRecognizer];
    
    // Define the images and add them to the scroll view
    self.images = @[@"Flight_out", @"Hotel", @"Goldfish", @"Saturday", @"Mormon", @"Flight_back"];
    [self createScrollableImages];

    [self showPage:0];
}

- (void)createScrollableImages
{
    // Update the page control
    self.pageControl.numberOfPages = self.images.count;
    
    // Add the images
    NSMutableDictionary *views  = [[NSMutableDictionary alloc] initWithDictionary:@{@"scrollview" : self.scrollView} ];
    
    for (NSString *imageName in self.images)
    {
        UIImage *image          = [UIImage imageNamed:imageName];
        UIImageView *imageView  = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode   = UIViewContentModeCenter;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollView addSubview:imageView];
        
        // Update values in the views dictionary to set up the constraints
        views[@"current"] = imageView;
        
        if (views[@"previous"] == nil)
        {
            // Pin the first image to the left
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[current]" options:0 metrics:nil views:views]];
        }
        else
        {
            // Subsequent views are added to the right of the previous row
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous][current]" options:0 metrics:nil views:views]];
        }
        
        // The width is the same as the scrollview and the height is fullscreen
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[current(==scrollview)]" options:0 metrics:nil views:views]];
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[current(==scrollview)]|" options:0 metrics:0 views:views]];
        
        // Store the reference for the next image
        views[@"previous"] = imageView;
    }
    
    // Finish the constraints
    if (views[@"previous"] != nil)
    {
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous]|" options:0 metrics:nil views:views]];
    }
}

- (void)showPage:(NSInteger)page
{
    self.pageControl.currentPage = page;
    
    AudioManager *audioManager = [AudioManager sharedManager];
    
    switch (page)
    {
        case PageFlightToNY:
        {
            [audioManager playFlightLoop];
            break;
        }
        case PageHotel:
        {
            [audioManager playHotel];
            break;
        }
        case PageConcert:
        {
            [audioManager playConcert];
            break;
        }
        case PageNothing:
        {
//            [audioManager playHappyBirthday];
            break;
        }
        case PageTheater:
        {
            [audioManager playTheater];
            break;
        }
        case PageFlightToGCM:
        {
            [audioManager playFlightLoop];
            break;
        }
    }
}

#pragma mark - Handle Swipes and Unwinding

- (IBAction)unwindSegue:(UIStoryboardSegue *)segue
{
    // Intentionally left blank
}

- (void)handleSwipe
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth       = CGRectGetWidth(scrollView.frame);
    float fractionalPage    = scrollView.contentOffset.x / pageWidth;
    [self showPage:lround(fractionalPage)];
}

#pragma mark - Getters

- (UISwipeGestureRecognizer *)swipeRecognizer
{
    if (_swipeRecognizer == nil)
    {
        _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe)];
        _swipeRecognizer.numberOfTouchesRequired = 1;
        _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _swipeRecognizer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
