//
//  TicketViewController.m
//  Niqui37
//
//  Created by Paulo Fierro on 18/02/2016.
//  Copyright © 2016 Paulo Fierro. All rights reserved.
//

#import "TicketViewController.h"

@interface TicketViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *images;

@end

@implementation TicketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Define the images
    self.images = @[@"Goldfish",@"Goldfish",@"Goldfish",@"Goldfish"];
    
    [self createScrollableImages];
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

#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth       = CGRectGetWidth(scrollView.frame);
    float fractionalPage    = scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = lround(fractionalPage);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
