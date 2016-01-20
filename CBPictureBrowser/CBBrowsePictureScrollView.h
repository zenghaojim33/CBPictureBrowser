//
//  CBBrowsePictureScrollView.h
//  91muzu
//
//  Created by ios app on 16/1/15.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissHandler)(void);


@interface CBBrowsePictureItem : NSObject

@property (nonatomic,strong) UIImage * thumbnail;
@property (nonatomic,strong)NSString * originalImageURL;
@property (nonatomic,assign)BOOL isInitialPicure;
@property (nonatomic,assign)CGRect originFrame;
@end

@interface CBBrowserView : UIView <UIScrollViewDelegate>

@property (nonatomic,copy)dismissHandler dismissHandler;

-(instancetype)initWithBrowserPicturesItems :(NSMutableArray *)pictures;

- (void) presentFromImageView :(UIImageView *)imageView toContainerView:(UIView *)containerView page:(NSInteger)page;

@end



@interface CBBrowsePictureScrollView : UIScrollView <UIScrollViewDelegate>

-(void)setup;

@property(nonatomic,strong)UIImageView *bornPicture;
@property(nonatomic,assign)CGRect initialRect;
@property(nonatomic,strong)NSMutableArray<CBBrowsePictureItem *> *allBrowsePictures;
@property(nonatomic,strong)NSMutableArray *subBrowsePictureScrollViews;
@property(nonatomic,strong)UIScrollView * currentSubBrowsePictureScrollView;
@property (nonatomic,weak) CBBrowserView * controlView;
@end

@interface CBBrowsePictureSubScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic,strong)CBBrowsePictureItem * item;
@property (nonatomic,strong)CAShapeLayer * progressLayer;
@property (nonatomic,strong)CALayer * maskLayer; //没加载完灰色的
@property (nonatomic,strong)UIImageView * imageView;
@end