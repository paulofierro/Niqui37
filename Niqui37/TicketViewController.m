//
//  TicketViewController.m
//  Niqui37
//
//  Created by Paulo Fierro on 18/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

@import AVFoundation;

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
    
    if ([AudioManager sharedManager].shouldAutomaticallyNavigate)
    {
        [AudioManager sharedManager].shouldAutomaticallyNavigate = NO;
        
        // If auto-navigation is on, we want to navigate the scrollbar based on when the tracks finish
        self.scrollView.userInteractionEnabled = NO;
        
        // Listen for when the audio tracks end
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    // Define the images and add them to the scroll view
    self.images = @[@"Flight_out", @"Hotel", @"Goldfish", @"Saturday", @"Mormon", @"Flight_back"];
    [self createScrollableImages];

    // Navigate to the first page
    [self navigateToPage:PageFlightToNY];
}

/// Force the navigation to a specific page in the scrollview
- (void)navigateToPage:(NSInteger)pageNumber
{
    CGFloat pageWidth   = CGRectGetWidth(self.scrollView.frame);
    CGPoint offset      = CGPointMake(pageWidth * pageNumber, 0);
    [self.scrollView setContentOffset:offset animated:YES];
    
    [self playAudioForPage:pageNumber];
}

/// Handle when a track has stopped playing stop receiving notification
/// We will automatically take the user to the next page
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    switch (self.pageControl.currentPage)
    {
        case PageFlightToNY:
        {
            [self navigateToPage:PageHotel];
            break;
        }
        case PageHotel:
        {
            [self navigateToPage:PageConcert];
            break;
        }
        case PageConcert:
        {
            [self navigateToPage:PageNothing];
            break;
        }
        case PageNothing:
        {
            [self navigateToPage:PageTheater];
            break;
        }
        case PageTheater:
        {
            [self navigateToPage:PageFlightToGCM];
            
            // Stop listening to notifications so auto navigation stops working
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            // Now that auto navigation is disabled, give control back to the user
            self.scrollView.userInteractionEnabled = YES;
            break;
        }
        case PageFlightToGCM:
        {
            break;
        }
    }
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

#pragma mark - Audio Methods

// Play audio for a specific page when a user has scrolled to it
- (void)playAudioForPage:(NSInteger)page
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
            [audioManager playNothing];
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

/// Needed for the Exit action in the Storyboard
- (IBAction)unwindSegue:(UIStoryboardSegue *)segue
{
    // Intentionally left blank
}

/// Handle downward swipes to close this view
- (void)handleSwipe
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Scroll View Delegate Methods

/// When the scroll view has been scrolled play the respective audio
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth       = CGRectGetWidth(scrollView.frame);
    float fractionalPage    = scrollView.contentOffset.x / pageWidth;
    [self playAudioForPage:lround(fractionalPage)];
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
