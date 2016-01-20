//
//  ViewController.m
//  CBPictureBrowser
//
//  Created by Anson_Company on 16/1/20.
//  Copyright © 2016年 Anson. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "CBBrowsePictureScrollView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;

@end

@implementation ViewController {

    NSArray * _originalImageUrlArray;
    NSArray<UIImageView *> * _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _originalImageUrlArray = [NSArray arrayWithObjects:@"http://developer.qiniu.com/resource/gogopher.jpg?imageMogr2",@"http://7xkwqs.com2.z0.glb.qiniucdn.com/FkLGTheMZixGA7U6CzMZmzuJBhee",@"http://7xkwqs.com2.z0.glb.qiniucdn.com/FobXg9ZpQKBi4ll3ELjgLGceueCv",nil];
    
    

    [self.image1 sd_setImageWithURL:[NSURL URLWithString:@"http://developer.qiniu.com/resource/gogopher.jpg?imageMogr2/thumbnail/!10p"] placeholderImage:nil];
    self.image1.userInteractionEnabled = YES;
    
    
    [self.image2 sd_setImageWithURL:[NSURL URLWithString:@"http://7xkwqs.com2.z0.glb.qiniucdn.com/FkLGTheMZixGA7U6CzMZmzuJBhee?imageMogr2/thumbnail/!10p"] placeholderImage:nil];
    self.image2.userInteractionEnabled = YES;


    [self.image3 sd_setImageWithURL:[NSURL URLWithString:@"http://7xkwqs.com2.z0.glb.qiniucdn.com/FobXg9ZpQKBi4ll3ELjgLGceueCv?imageMogr2/thumbnail/!10p"] placeholderImage:nil];
    self.image3.userInteractionEnabled = YES;

    _images = [NSArray arrayWithObjects:self.image1,self.image2,self.image3, nil];
}


- (IBAction)tap:(UITapGestureRecognizer *)tap {
    
    
    
    NSInteger page = tap.view.tag;
    NSMutableArray * items = [NSMutableArray array];
    
    for (NSInteger i = 0 ; i < 3 ; i ++){
        
        CBBrowsePictureItem * item = [[CBBrowsePictureItem alloc]init];
        item.originalImageURL = _originalImageUrlArray[i];
        item.thumbnail =  [_images[i].image copy];
        CGRect originFrame = [tap.view convertRect:tap.view.bounds toView:self.view];
        item.originFrame = originFrame;
        if (i == page) {
            item.isInitialPicure = YES;
        }
        [items addObject:item];

    }
    
    CBBrowserView * browser = [[CBBrowserView alloc]initWithBrowserPicturesItems:items];
    [browser presentFromImageView:(UIImageView *)tap.view toContainerView:self.view page:page];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    browser.dismissHandler = ^ {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
    };
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
