//
//  Demo1ViewController.m
//  照片选择器
//
//  Created by 洪欣 on 17/2/17.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "Demo1ViewController.h"
#import "HXPhotoPicker.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface Demo1ViewController ()<HXCustomNavigationControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *total;
//@property (weak, nonatomic) IBOutlet UILabel *photo;
//@property (weak, nonatomic) IBOutlet UILabel *video;
@property (weak, nonatomic) IBOutlet UILabel *original;
@property (weak, nonatomic) IBOutlet UISwitch *camera;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (weak, nonatomic) IBOutlet UITextField *photoText;
@property (weak, nonatomic) IBOutlet UITextField *videoText;
@property (weak, nonatomic) IBOutlet UITextField *totalText;
@property (weak, nonatomic) IBOutlet UITextField *columnText;
@property (weak, nonatomic) IBOutlet UISwitch *addCamera; 
@property (weak, nonatomic) IBOutlet UISwitch *showHeaderSection;
@property (weak, nonatomic) IBOutlet UISwitch *reverse;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectedTypeView;
@property (weak, nonatomic) IBOutlet UISwitch *saveAblum;
@property (weak, nonatomic) IBOutlet UISwitch *icloudSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *downloadICloudAsset;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tintColor;
@property (weak, nonatomic) IBOutlet UISwitch *hideOriginal;
@property (weak, nonatomic) IBOutlet UISwitch *synchTitleColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navBgColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navTitleColor;
@property (weak, nonatomic) IBOutlet UISwitch *useCustomCamera;
@property (strong, nonatomic) UIColor *bottomViewBgColor; 
@property (weak, nonatomic) IBOutlet UITextField *clarityText;
@property (weak, nonatomic) IBOutlet UISwitch *photoCanEditSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *videoCanEditSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *albumShowModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *createTimeSortSwitch;

@end

@implementation Demo1ViewController

- (HXPhotoManager *)manager
{
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.videoMaxNum = 5;
        _manager.configuration.deleteTemporaryPhoto = NO;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.saveSystemAblum = YES;
        _manager.configuration.selectTogether = YES;
        _manager.configuration.creationDateSort = YES;
//       _manager.configuration.cellSelectedBgColor = [UIColor colorWithRed:80/255.0 green:169/255.0 blue:56/255.0 alpha:1];//背景
//       _manager.configuration.selectedTitleColor = [UIColor whiteColor];//文字
   
//        _manager.configuration.supportRotation = NO;
//        _manager.configuration.cameraCellShowPreview = NO;
//        _manager.configuration.themeColor = [UIColor redColor];
        _manager.configuration.navigationBar = ^(UINavigationBar *navigationBar, UIViewController *viewController) {
//            [navigationBar setBackgroundImage:[UIImage imageNamed:@"APPCityPlayer_bannerGame"] forBarMetrics:UIBarMetricsDefault];
//            navigationBar.barTintColor = [UIColor redColor];
        };
//        _manager.configuration.sectionHeaderTranslucent = NO;
//        _manager.configuration.navBarBackgroudColor = [UIColor redColor];
//        _manager.configuration.sectionHeaderSuspensionBgColor = [UIColor redColor];
//        _manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
//        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
       // _manager.configuration.selectedTitleColor = [UIColor redColor];
        
//        _manager.configuration.requestImageAfterFinishingSelection = YES;
        
        __weak typeof(self) weakSelf = self;
        _manager.configuration.photoListBottomView = ^(HXPhotoBottomView *bottomView) {
          
        };
        _manager.configuration.previewBottomView = ^(HXPhotoPreviewBottomView *bottomView) {
           
        };
        _manager.configuration.albumListCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"albumList:%@",collectionView);
        };
        _manager.configuration.photoListCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"photoList:%@",collectionView);
        };
        _manager.configuration.previewCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"preview:%@",collectionView);
        };

        

    }
    return _manager;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXWeakSelf
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:image location:nil complete:^(HXPhotoModel *model, BOOL success) {
                if (success) {
                    if (weakSelf.manager.configuration.useCameraComplete) {
                        weakSelf.manager.configuration.useCameraComplete(model);
                    }
                }else {
                    [weakSelf.view hx_showImageHUDText:@"保存图片失败"];
                }
            }];
        }else {
            HXPhotoModel *model = [HXPhotoModel photoModelWithImage:image];
            if (self.manager.configuration.useCameraComplete) {
                self.manager.configuration.useCameraComplete(model);
            }
        }
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url location:nil complete:^(HXPhotoModel *model, BOOL success) {
                if (success) {
                    if (weakSelf.manager.configuration.useCameraComplete) {
                        weakSelf.manager.configuration.useCameraComplete(model);
                    }
                }else {
                    [weakSelf.view hx_showImageHUDText:@"保存视频失败"];
                }
            }];
        }else {
            HXPhotoModel *model = [HXPhotoModel photoModelWithVideoURL:url];
            if (self.manager.configuration.useCameraComplete) {
                self.manager.configuration.useCameraComplete(model);
            }
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空选择" style:UIBarButtonItemStylePlain target:self action:@selector(didRightClick)];
    self.scrollView.delegate = self;
    if (HX_IS_IPhoneX_All) {
        self.clarityText.text = @"2.4";
    }else if ([UIScreen mainScreen].bounds.size.width == 320) {
        self.clarityText.text = @"1.2";
    }else if ([UIScreen mainScreen].bounds.size.width == 375) {
        self.clarityText.text = @"1.8";
    }else {
        self.clarityText.text = @"2.0";
    } 
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)didRightClick {
    [self.manager clearSelectedList];
    self.total.text = @"总数量：0   ( 照片：0   视频：0 )";
    self.original.text = @"NO";
}
- (IBAction)goAlbum:(id)sender {
   
    HXWeakSelf
    [self hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL isOriginal, UIViewController *viewController, HXPhotoManager *manager) {
        weakSelf.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
        weakSelf.original.text = isOriginal ? @"YES" : @"NO";
        NSSLog(@"block - all - %@",allList);
        NSSLog(@"block - photo - %@",photoList);
        NSSLog(@"block - video - %@",videoList);
//        [photoList hx_requestImageWithOriginal:NO completion:^(NSArray<UIImage *> * _Nullable imageArray, NSArray<HXPhotoModel *> * _Nullable errorArray) {
//            NSSLog(@"images - %@", imageArray);
//        }];
    } cancel:^(UIViewController *viewController, HXPhotoManager *manager) {
        NSSLog(@"block - 取消了");
    }];
}
- (IBAction)selectTypeClick:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.manager.type = HXPhotoManagerSelectedTypePhoto;
    }else if (sender.selectedSegmentIndex == 1) {
        self.manager.type = HXPhotoManagerSelectedTypeVideo;
    }else {
        self.manager.type = HXPhotoManagerSelectedTypePhotoAndVideo;
    }
    [self.manager clearSelectedList];
}
- (void)albumListViewController:(HXAlbumListViewController *)albumListViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original {
    self.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
    //    [NSString stringWithFormat:@"%ld个",allList.count];
    //    self.photo.text = [NSString stringWithFormat:@"%ld张",photos.count];
    //    self.video.text = [NSString stringWithFormat:@"%ld个",videos.count];
    self.original.text = original ? @"YES" : @"NO";
    NSSLog(@"delegate - all - %@",allList);
    NSSLog(@"delegate - photo - %@",photoList);
    NSSLog(@"delegate - video - %@",videoList);
}
- (IBAction)tb:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.navigationTitleSynchColor = sw.on;
}
- (IBAction)yc:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.hideOriginalBtn = sw.on;
}

- (IBAction)same:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.selectTogether = sw.on;
}

- (IBAction)isLookGIFPhoto:(UISwitch *)sender {
    self.manager.configuration.lookGifPhoto = sender.on;
}

- (IBAction)isLookLivePhoto:(UISwitch *)sender {
    self.manager.configuration.lookLivePhoto = sender.on;
}
- (IBAction)photoCanEditClick:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.photoCanEdit = sw.on;
}
- (IBAction)videoCaneEditClick:(UISwitch *)sender {
    self.manager.configuration.videoCanEdit = sender.on;
}

- (IBAction)addCamera:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.openCamera = sw.on;
} 
- (IBAction)createTimeSortSwitch:(UISwitch *)sender {
    [self.manager removeAllAlbum];
    [self.manager removeAllTempList];
}
- (void)dealloc {
    NSSLog(@"dealloc");
    self.scrollView.delegate = nil;
}
@end
