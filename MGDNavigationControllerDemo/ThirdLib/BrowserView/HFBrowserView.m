//
//  HFBrowserView.m
//  HGYProject
//
//  Created by HF Zhao on 13-8-3.
//  Copyright (c) 2013年 HuiGeYuan. All rights reserved.
//

#import "HFBrowserView.h"

#define HFBrowserViewPADDING                 0
#define HFBrowserViewPAGE_INDEX_TAG_OFFSET   1000
#define HFBrowserViewPAGE_INDEX(page)        ([(page) tag] - HFBrowserViewPAGE_INDEX_TAG_OFFSET)

@interface HFBrowserView () {
    
}
// Layout
- (void)performLayout;

// Paging
- (void)tilePages;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
@end

@implementation HFBrowserView
- (void)setUp:(CGRect)frame
{
    _pageCount = NSNotFound;
    _performingLayout = NO; // Reset on view did appearß
    _currentPageIndex = 0;
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
    isReload = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pagingEnabled = YES;
	self.delegate = self;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
    
    // Update
//    [self reloadData];
    
//    UISwipeGestureRecognizer* recognizer;
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:recognizer];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:recognizer];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setUp:self.frame];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp:frame];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setInitialPageIndex:(NSUInteger)index {
    // Validate
    [self setInitialPageIndex:index animated:YES];
	
}
-(void)setInitialPageIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= [self numberOfPhotos]) index = [self numberOfPhotos]-1;
    _currentPageIndex = index;
    if (isReload) {
        [self jumpToPageAtIndex:index animated:animated];
    }
}
-(int)getCurrentPage
{
    return _currentPageIndex;
}
- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	[self jumpToPageAtIndex:index animated:YES];
	
}
-(void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index < [self numberOfPhotos]) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
        //		self.contentOffset = CGPointMake(pageFrame.origin.x - HFBrowserViewPADDING, 0);
        [self setContentOffset:CGPointMake(pageFrame.origin.x - HFBrowserViewPADDING, 0) animated:animated];
        if ([self.dragDelegate respondsToSelector:@selector(browserViewlWillSelect:pageView:pageIndex:)]) {
            [self.dragDelegate browserViewlWillSelect:self pageView:[self pageDisplayedAtIndex:_currentPageIndex] pageIndex:_currentPageIndex];
        }
	}
}
- (void)reloadData {
    
    // Reset
    _pageCount = NSNotFound;
    isReload = YES;
    // Update
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self performLayout];
    
    // Layout
//    [self setNeedsLayout];
    
}
- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    self.contentSize = [self contentSizeForPagingScrollView];
	// Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Content offset
	self.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
    
}
- (NSUInteger)numberOfPhotos {
    if (_pageCount == NSNotFound) {
        if ([_sourceDelegate respondsToSelector:@selector(numberOfPageInBrowserView:)]) {
            _pageCount = [_sourceDelegate numberOfPageInBrowserView:self];
        }
    }
    if (_pageCount == NSNotFound) _pageCount = 0;
    return _pageCount;
}
#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= HFBrowserViewPADDING;
    frame.size.width += (2 * HFBrowserViewPADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = self.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * HFBrowserViewPADDING);
    pageFrame.origin.x = (bounds.size.width * index) + HFBrowserViewPADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = self.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = self.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

#pragma mark - Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = self.bounds;
	int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+HFBrowserViewPADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-HFBrowserViewPADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
	
	// Recycle no longer needed pages
    NSInteger pageIndex;
	for (UIView *page in _visiblePages) {
        pageIndex = HFBrowserViewPAGE_INDEX(page);
		if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
			[_recycledPages addObject:page];
			[page removeFromSuperview];
			NSLog(@"Removed page at index %i", HFBrowserViewPAGE_INDEX(page));
		}
	}
	[_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 10) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
			UIView *page = [self dequeueRecycledPage:index];
            if(page == nil) {
                page = [self.sourceDelegate browserView:self viewAtIndex:index];
            }
            
			[self configurePage:page forIndex:index];
			[_visiblePages addObject:page];
			[self addSubview:page];
			NSLog(@"Added page at index %i", index);
            
		}
	}
	
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (UIView *page in _visiblePages)
		if (HFBrowserViewPAGE_INDEX(page) == index) return YES;
	return NO;
}
-(UIView *)getCurrentView
{
    return [self pageDisplayedAtIndex:_currentPageIndex];
}
-(UIView *)getView:(int)index
{
    UIView *theView = [self viewWithTag:HFBrowserViewPAGE_INDEX_TAG_OFFSET + index];
    if (!theView) {
        theView = [self dequeueRecycledPage:index];
    }
    return theView;
}
- (UIView *)pageDisplayedAtIndex:(NSUInteger)index {
	UIView *thePage = nil;
	for (UIView *page in _visiblePages) {
		if (HFBrowserViewPAGE_INDEX(page) == index) {
			thePage = page; break;
		}
	}
	return thePage;
}
- (UIView *)dequeueRecycledPage:(NSUInteger)index {
    UIView *page = nil;
    NSArray *array = [_recycledPages allObjects];
    for(UIView *home in array) {
        if(home.tag == HFBrowserViewPAGE_INDEX_TAG_OFFSET + index) {
            page = home;
            break;
        }
    }
    return page;
}
- (void)configurePage:(UIView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
    page.tag = HFBrowserViewPAGE_INDEX_TAG_OFFSET + index;
}

//- (MWZoomingScrollView *)dequeueRecycledPage {
//	MWZoomingScrollView *page = [_recycledPages anyObject];
//	if (page) {
//		[[page retain] autorelease];
//		[_recycledPages removeObject:page];
//	}
//	return page;
//}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
    // Checks
	if (_performingLayout) return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = self.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
	NSUInteger previousCurrentPage = _currentPageIndex;
	_currentPageIndex = index;
	if (_currentPageIndex != previousCurrentPage) {
//        [self didStartViewingPageAtIndex:index];
    }
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSLog(@"scrollViewDidEndDecelerating");
    if ([self.dragDelegate respondsToSelector:@selector(browserViewlDidEndDecelerating:pageView:pageIndex:)]) {
        [self.dragDelegate browserViewlDidEndDecelerating:self pageView:[self pageDisplayedAtIndex:_currentPageIndex] pageIndex:_currentPageIndex];
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndScrollingAnimation");
    if ([self.dragDelegate respondsToSelector:@selector(browserViewlDidEndScrollingAnimation:pageView:pageIndex:)]) {
        [self.dragDelegate browserViewlDidEndScrollingAnimation:self pageView:[self pageDisplayedAtIndex:_currentPageIndex] pageIndex:_currentPageIndex];
    }
}

@end
