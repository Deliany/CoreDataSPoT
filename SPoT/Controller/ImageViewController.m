//
//  ImageViewController.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 28.02.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "ImageViewController.h"
#import "AttributedStringViewController.h"
#import "NetworkActivityIndicatorManager.h"
#import "ImageCacheManager.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation ImageViewController

#pragma mark - Segue methods

// returns whether the "Show URL" segue should be allowed to fire
// prohibits the segue if we don't have a URL set in us yet or
//  if a popover showing the URL is already visible

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]) {
        return (self.imageURL && !self.urlPopover.popoverVisible) ? YES : NO;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

// uses an AttributedStringViewController to display the URL of the image we are currently displaying
// if being presented by a Popover segue, grab ahold of the popover so that we can avoid
//  putting it up multiple times (by prohibiting it in shouldPerformSegueWithIdentfier:sender:)

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]) {
            AttributedStringViewController *asc = (AttributedStringViewController *)segue.destinationViewController;
            asc.text = [[NSAttributedString alloc] initWithString:[self.imageURL description]];
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            }
        }
    }
}

#pragma mark - Properties methods


// set splitViewBarButtonItem when we are in split view controller

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) {
        [toolbarItems removeObject:_splitViewBarButtonItem];
    }
    // put the bar button on the left of our existing toolbar
    if (barButtonItem) {
        [toolbarItems insertObject:barButtonItem atIndex:0];
    }
    self.toolbar.items = toolbarItems;
    
    _splitViewBarButtonItem = barButtonItem;
}

// sets the title of the titleBarButtonItem (if connected) to the passed title

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}


#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        NSURL *savedImageURL = self.imageURL;
        
        [self.activityIndicator startAnimating];
        
        dispatch_queue_t imageLoadQueue = dispatch_queue_create("image downloading", NULL);
        dispatch_async(imageLoadQueue, ^{
            NSData *imageData;
            NSString *fileName = [[self.imageURL pathComponents] lastObject];
            
            NSData *dataFromCache = [ImageCacheManager getImageFromCacheWithName:fileName];
            if (dataFromCache) {
                imageData = dataFromCache;
            }
            else {
                [NetworkActivityIndicatorManager networkActivityIndicatorShouldShow];
                imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
                [NetworkActivityIndicatorManager networkActivityIndicatorShouldHide];
                
                [ImageCacheManager writeImageToCacheWithData:imageData andFileName:fileName];
            }
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            if (self.imageURL == savedImageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (image) {                    
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        
                        [self viewDidLayoutSubviews];
                    }
                    [self.activityIndicator stopAnimating];
                });
            }
            
        });
        
    }
}


// sets the title of the titleBarButtonItem (if connected) to self.title
//  (just in case setTitle: was called before self.titleBarButtonItem outlet was loaded)

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    self.titleBarButtonItem.title = self.title;
}

// after every bounds change set the zoomScale to show as much of the photo as possible with
//  no extra unused space

- (void)viewDidLayoutSubviews
{    
    CGFloat scaleWidth = self.scrollView.bounds.size.width / self.imageView.bounds.size.width;
    CGFloat scaleHeight = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
    
    if (!scaleWidth == 0 && !scaleHeight == 0) {
        self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
        self.scrollView.zoomScale = MAX(scaleWidth, scaleHeight);
    }
    
    [self centerScrollViewContents];
    
    // whenever we change our bounds check if splitViewBarButtonItem should be set or not
    self.splitViewBarButtonItem = self.splitViewBarButtonItem;
}

// positioning the image view such that it is always in the center of the scroll view’s bounds

- (void)centerScrollViewContents {
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < self.scrollView.bounds.size.width) {
        contentsFrame.origin.x = (self.scrollView.bounds.size.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < self.scrollView.bounds.size.height) {
        contentsFrame.origin.y = (self.scrollView.bounds.size.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}


@end
