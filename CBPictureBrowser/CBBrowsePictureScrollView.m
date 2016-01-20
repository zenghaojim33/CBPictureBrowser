//
//  CBBrowsePictureScrollView.m
//  91muzu
//
//  Created by ios app on 16/1/15.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "CBBrowsePictureScrollView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"

#define PictureSpace 20
#define SCREEN_WIDTH MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)



@implementation CBBrowsePictureItem

@end


/**
 *  主View
 */

@interface CBBrowserView ()
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)CBBrowsePictureScrollView * scrollView;
@property (nonatomic,strong)UIPageControl * pageControl;
@end


@implementation CBBrowserView

-(instancetype)initWithBrowserPicturesItems :(NSMutableArray *)pictures {
    
    if (self = [super init]) {
        
        /**
         ScrollView
         */

        self.backgroundColor = [UIColor blackColor];
        self.frame = [[UIScreen mainScreen] bounds];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoom:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [tap requireGestureRecognizerToFail:doubleTap];
        
        
        _scrollView = [[CBBrowsePictureScrollView alloc]init];
        _scrollView.frame =  CGRectMake(-PictureSpace/2, 0, self.frame.size.width+PictureSpace, self.frame.size.height);
        _scrollView.allBrowsePictures = pictures;
        _scrollView.delegate = self;
        _scrollView.controlView = self;
        _scrollView.contentSize=CGSizeMake((self.bounds.size.width+PictureSpace) * pictures.count,self.bounds.size.height);
        
        [self addSubview:_scrollView];
        
        /**
         PageControl
         */
        UIPageControl *pageControl=[[UIPageControl alloc]init];
        pageControl.numberOfPages=self.scrollView.allBrowsePictures.count;
        pageControl.center=CGPointMake(self.center.x, self.frame.size.height-50);
        
        self.pageControl=pageControl;
        self.pageControl.currentPage=(int)(self.scrollView.contentOffset.x/self.frame.size.width+0.5);
        [self addSubview:pageControl];
    }
    
    return self;
}


- (void)presentFromImageView :(UIImageView *)imageView toContainerView:(UIView *)containerView page:(NSInteger)page{
    
    self.scrollView.bornPicture = imageView;
    self.currentPage = page;
    self.scrollView.initialRect = [imageView convertRect:imageView.bounds toView:containerView];
    
    [containerView addSubview:self];
    [self.scrollView setup];

}

-(void)dismiss {
    self.dismissHandler();

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

-(void)zoom:(UITapGestureRecognizer *)tap {
    
    CBBrowsePictureSubScrollView * subScrollView = self.scrollView.subBrowsePictureScrollViews[self.currentPage];
    if (subScrollView){
        if (subScrollView.zoomScale > 1){
            [subScrollView setZoomScale:1 animated:YES];
        }else{
            CGPoint touchPoint = [tap locationInView:subScrollView.imageView];
            CGFloat newZoomScale = subScrollView.maximumZoomScale;
            CGFloat xsize = self.frame.size.width / newZoomScale;
            CGFloat ysize = self.frame.size.height / newZoomScale;
            [subScrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];

        }
    }
    
}


#pragma mark   - UIScrollViewDelegate


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    double page=scrollView.contentOffset.x/scrollView.frame.size.width;
    self.currentPage = self.pageControl.currentPage=(int)(page+0.5);
    
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CBBrowsePictureSubScrollView * subScrollView = self.scrollView.subBrowsePictureScrollViews[self.currentPage];
    [subScrollView setZoomScale:1 animated:YES];

}

@end

@implementation CBBrowsePictureScrollView





-(void)setup {
    
    
    self.backgroundColor=[UIColor blackColor];
    self.pagingEnabled=YES;
    self.showsHorizontalScrollIndicator=NO;
    self.showsVerticalScrollIndicator=NO;
    
    NSInteger currentPage = self.controlView.currentPage;
    
    _subBrowsePictureScrollViews = [[NSMutableArray alloc]init];
    
    
    for (int i=0;i<self.allBrowsePictures.count;i++) {
        
        CBBrowsePictureItem *browsePictureItem =self.allBrowsePictures[i];
        CBBrowsePictureSubScrollView *subBrowsePictureScrollView=[[CBBrowsePictureSubScrollView alloc]initWithFrame:CGRectMake(i * (PictureSpace  + SCREEN_WIDTH) + PictureSpace / 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        [self addSubview:subBrowsePictureScrollView];
        [_subBrowsePictureScrollViews addObject:subBrowsePictureScrollView];
        
        
        [subBrowsePictureScrollView setItem:browsePictureItem];


    }
    [self setContentOffset:CGPointMake(currentPage * (PictureSpace  + SCREEN_WIDTH), 0)];


}


@end






@implementation CBBrowsePictureSubScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.showsHorizontalScrollIndicator=NO;
        self.showsVerticalScrollIndicator=NO;
        self.backgroundColor = [UIColor clearColor];
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 2.0;
        self.delegate = self;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceVertical = NO;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        _imageView = [[UIImageView alloc]init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _maskLayer = [CALayer layer];
        _maskLayer.frame = self.bounds;
        _maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        _maskLayer.opacity = 0.7 ;
        _maskLayer.hidden = YES;
        [self.layer addSublayer:_maskLayer];
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(self.frame.size.width/2 - 20, self.frame.size.height/2 - 20, 40, 40);
        _progressLayer.cornerRadius = 20;
        _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
        _progressLayer.path = path.CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineWidth = 4;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
        
        

        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.frame = CGRectMake(self.frame.size.width/2 -20 , self.frame.size.height/2 - 20, 40, 40);
    _maskLayer.frame = self.bounds;
}

-(void)setItem:(CBBrowsePictureItem *)item{
    
    if (!item) return;

    [self allowZooming:NO];
    CGRect calculatedRect;
    if (item.thumbnail){
        calculatedRect =  AVMakeRectWithAspectRatioInsideRect(item.thumbnail.size,[UIScreen mainScreen].bounds);
    }
    [_imageView setImage:item.thumbnail];
    
    if (item.isInitialPicure){
        _imageView.frame = item.originFrame;
        [UIView animateWithDuration:0.3 animations:^{
            
            _imageView.frame = calculatedRect;
            
        } completion:^(BOOL finished) {

            [_imageView sd_setImageWithURL:[NSURL URLWithString:item.originalImageURL] placeholderImage:item.thumbnail options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                _progressLayer.hidden = NO;
                float progress = (float)receivedSize / (float)expectedSize;
                [_progressLayer setStrokeEnd:progress];
                _maskLayer.hidden = NO;
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [_imageView setImage:image];
                _progressLayer.hidden = YES;
                _maskLayer.hidden = YES;
                [self allowZooming:YES];
            }];
            

            
            
        }];
    }else{

        _imageView.frame = calculatedRect;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:item.originalImageURL] placeholderImage:item.thumbnail options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            _progressLayer.hidden = NO;
            float progress = (float)receivedSize / (float)expectedSize;
            [_progressLayer setStrokeEnd:progress];
            _maskLayer.hidden = NO;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_imageView setImage:image];
            _progressLayer.hidden = YES;
            _maskLayer.hidden = YES;
            [self allowZooming:YES];
        }];

    }


}

-(void)allowZooming:(BOOL)allow {
    
    if (!allow) {
        self.maximumZoomScale = 1.0f;
        self.minimumZoomScale = 1.0f;
    }else{
        self.maximumZoomScale = 2.0f;
        self.minimumZoomScale = 1.0f;
    }
    
}


#pragma mark -- UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(CBBrowsePictureSubScrollView *)scrollView {
    
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView{
    CGFloat offsetX = (aScrollView.bounds.size.width > aScrollView.contentSize.width)?
    (aScrollView.bounds.size.width - aScrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (aScrollView.bounds.size.height > aScrollView.contentSize.height)?
    (aScrollView.bounds.size.height - aScrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(aScrollView.contentSize.width * 0.5 + offsetX,
                                       aScrollView.contentSize.height * 0.5 + offsetY);
}
@end
