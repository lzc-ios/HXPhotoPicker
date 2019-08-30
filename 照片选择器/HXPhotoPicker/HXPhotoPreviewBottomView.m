//
//  HXPhotoPreviewBottomView.m
//  照片选择器
//
//  Created by 洪欣 on 2017/10/16.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "HXPhotoPreviewBottomView.h"
#import "HXPhotoManager.h"
#import "UIImageView+HXExtension.h"
@interface HXPhotoPreviewBottomView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *editBtn;
@property (strong, nonatomic) HXPhotoManager *manager;
@end

@implementation HXPhotoPreviewBottomView
- (instancetype)initWithFrame:(CGRect)frame modelArray:(NSArray *)modelArray manager:(HXPhotoManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        self.manager = manager;
        self.modelArray = [NSMutableArray arrayWithArray:modelArray];
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    _currentIndex = -1;
    [self addSubview:self.bgView];
    [self addSubview:self.collectionView];
    [self addSubview:self.doneBtn];
    [self addSubview:self.editBtn];
    [self addSubview:self.tipView];
    [self changeDoneBtnFrame];
}
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.editBtn.enabled = enabled;
}
- (void)setHideEditBtn:(BOOL)hideEditBtn {
    _hideEditBtn = hideEditBtn;
    if (hideEditBtn) {
        [self.editBtn removeFromSuperview];
        [self layoutSubviews];
    }else {
        [self addSubview:self.editBtn];
    }
}
- (void)setOutside:(BOOL)outside {
    _outside = outside;
    if (outside) {
        self.doneBtn.hidden = YES;
    }
}
- (void)changeTipViewState:(HXPhotoModel *)model {
    NSString *tipText;
    if (!self.manager.configuration.selectTogether) {
        if (self.manager.selectedPhotoCount && model.subType == HXPhotoModelMediaSubTypeVideo) {
            tipText = [NSBundle hx_localizedStringForKey:@"选择照片时不能选择视频"];
        }else if (self.manager.selectedVideoCount && model.subType == HXPhotoModelMediaSubTypePhoto) {
            tipText = [NSBundle hx_localizedStringForKey:@"选择视频时不能选择照片"];
        }
    }
    if (model.subType == HXPhotoModelMediaSubTypeVideo && !tipText) {
        if (model.videoDuration >= self.manager.configuration.videoMaximumSelectDuration + 1) {
            if (self.manager.configuration.videoCanEdit) {
                tipText = [NSString stringWithFormat:[NSBundle hx_localizedStringForKey:@"只能选择%ld秒内的视频，需进行编辑"], self.manager.configuration.videoMaximumSelectDuration];
            }else {
                tipText = [NSString stringWithFormat:[NSBundle hx_localizedStringForKey:@"视频大于%ld秒，无法选择"], self.manager.configuration.videoMaximumSelectDuration];
            }
        }else if (model.videoDuration < self.manager.configuration.videoMinimumSelectDuration) {
            tipText = [NSString stringWithFormat:[NSBundle hx_localizedStringForKey:@"视频少于%ld秒，无法选择"], self.manager.configuration.videoMinimumSelectDuration];
        }
    }
    self.tipLb.text = tipText;
    self.tipView.hidden = !tipText;
    self.collectionView.hidden = tipText;
}
- (void)insertModel:(HXPhotoModel *)model {
    [self.modelArray addObject:model];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.modelArray.count - 1 inSection:0]]];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.modelArray.count - 1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    self.currentIndex = self.modelArray.count - 1;
}
- (void)deleteModel:(HXPhotoModel *)model {
    if ([self.modelArray containsObject:model] && self.currentIndex >= 0) {
        NSInteger index = [self.modelArray indexOfObject:model];
        [self.modelArray removeObject:model];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        _currentIndex = -1;
    }
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex == currentIndex) {
        return;
    }
    if (currentIndex < 0 || currentIndex > self.modelArray.count - 1) {
        return;
    }
    _currentIndex = currentIndex;
    self.currentIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    
    [self.collectionView selectItemAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}
- (void)setSelectCount:(NSInteger)selectCount {
    _selectCount = selectCount;
    NSString *text;
    if (selectCount <= 0) {
        text = @"";
        [self.doneBtn setTitle:[NSBundle hx_localizedStringForKey:@"完成"] forState:UIControlStateNormal];
    }else {
        if (self.manager.configuration.doneBtnShowDetail) {
            if (!self.manager.configuration.selectTogether) {
                if (self.manager.selectedPhotoCount > 0) {
                    NSInteger maxCount = self.manager.configuration.photoMaxNum > 0 ? self.manager.configuration.photoMaxNum : self.manager.configuration.maxNum;
                    text = [NSString stringWithFormat:@"(%ld/%ld)", selectCount,maxCount];
                }else {
                    NSInteger maxCount = self.manager.configuration.videoMaxNum > 0 ? self.manager.configuration.videoMaxNum : self.manager.configuration.maxNum;
                    text = [NSString stringWithFormat:@"(%ld/%ld)", selectCount,maxCount];
                }
            }else {
                text = [NSString stringWithFormat:@"(%ld/%ld)", selectCount,self.manager.configuration.maxNum];
            }
        }else {
            text = [NSString stringWithFormat:@"(%ld)", selectCount];
        }
    }
    [self.doneBtn setTitle:[NSString stringWithFormat:@"%@%@",[NSBundle hx_localizedStringForKey:@"完成"], text] forState:UIControlStateNormal];
    [self changeDoneBtnFrame];
}
#pragma mark - < UICollectionViewDataSource >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.modelArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXPhotoPreviewBottomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DatePreviewBottomViewCellId" forIndexPath:indexPath];
    cell.selectColor = self.manager.configuration.themeColor;
    HXPhotoModel *model = self.modelArray[indexPath.item];
    cell.model = model;
    return cell;
}
#pragma mark - < UICollectionViewDelegate >
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delagate respondsToSelector:@selector(photoPreviewBottomViewDidItem:currentIndex:beforeIndex:)]) {
        [self.delagate photoPreviewBottomViewDidItem:self.modelArray[indexPath.item] currentIndex:indexPath.item beforeIndex:self.currentIndex];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(HXPhotoPreviewBottomViewCell *)cell cancelRequest];
}
- (void)deselectedWithIndex:(NSInteger)index {
    if (index < 0 || index > self.modelArray.count - 1 || self.currentIndex < 0) {
        return;
    }
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:NO];
    _currentIndex = -1;
}

- (void)deselected {
    if (self.currentIndex < 0 || self.currentIndex > self.modelArray.count - 1) {
        return;
    }
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] animated:NO];
    _currentIndex = -1;
}

- (void)didDoneBtnClick {
    if ([self.delagate respondsToSelector:@selector(photoPreviewBottomViewDidDone:)]) {
        [self.delagate photoPreviewBottomViewDidDone:self];
    }
}
- (void)didEditBtnClick {
    if ([self.delagate respondsToSelector:@selector(photoPreviewBottomViewDidEdit:)]) {
        [self.delagate photoPreviewBottomViewDidEdit:self];
    }
}
- (void)changeDoneBtnFrame {
    if (self.outside) {
        if (self.manager.afterSelectedPhotoArray.count && self.manager.afterSelectedVideoArray.count) {
            if (!self.manager.configuration.videoCanEdit && !self.manager.configuration.photoCanEdit) {
                if (self.collectionView.hx_w != self.hx_w - 12) self.collectionView.hx_w = self.hx_w - 12;
            }else {
                self.editBtn.hx_x = self.hx_w - 12 - self.editBtn.hx_w;
                if (self.collectionView.hx_w != self.editBtn.hx_x) self.collectionView.hx_w = self.editBtn.hx_x;
            }
        }else {
            if (self.hideEditBtn) {
                if (self.collectionView.hx_w != self.hx_w - 12) self.collectionView.hx_w = self.hx_w - 12;
            }else {
                self.editBtn.hx_x = self.hx_w - 12 - self.editBtn.hx_w;
                if (self.collectionView.hx_w != self.editBtn.hx_x) self.collectionView.hx_w = self.editBtn.hx_x;
            }
        }
    }else {
        
        CGFloat width = self.doneBtn.titleLabel.hx_getTextWidth;
        self.doneBtn.hx_w = width + 20;
        if (self.doneBtn.hx_w < 50) {
            self.doneBtn.hx_w = 50;
        }
        self.doneBtn.hx_x = self.hx_w - 12 - self.doneBtn.hx_w;
        self.editBtn.hx_x = self.doneBtn.hx_x - self.editBtn.hx_w;
        if (self.manager.type == HXPhotoManagerSelectedTypePhoto || self.manager.type == HXPhotoManagerSelectedTypeVideo) {
            if (!self.hideEditBtn) {
                if (self.collectionView.hx_w != self.editBtn.hx_x) self.collectionView.hx_w = self.editBtn.hx_x;
            }else {
                if (self.collectionView.hx_w != self.doneBtn.hx_x - 12) self.collectionView.hx_w = self.doneBtn.hx_x - 12;
            }
        }else {
            if (!self.manager.configuration.videoCanEdit && !self.manager.configuration.photoCanEdit) {
                if (self.collectionView.hx_w != self.doneBtn.hx_x - 12) self.collectionView.hx_w = self.doneBtn.hx_x - 12;
            }else {
                if (self.collectionView.hx_w != self.editBtn.hx_x) self.collectionView.hx_w = self.editBtn.hx_x;
            }
        }
    }
    self.tipView.frame = self.collectionView.frame;
    
    self.tipLb.frame = CGRectMake(12, 0, self.tipView.hx_w - 12, self.tipView.hx_h);
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgView.frame = self.bounds;
 
    self.doneBtn.frame = CGRectMake(0, 0, 50, 30);
    self.doneBtn.center = CGPointMake(self.doneBtn.center.x, 25);
    
    
    [self changeDoneBtnFrame];
}
#pragma mark - < 懒加载 >
- (UIToolbar *)bgView {
    if (!_bgView) {
        _bgView = [[UIToolbar alloc] init];
        if (self.manager.configuration.isWXStyle) {
             _bgView.barTintColor = [UIColor blackColor];
        }
      
    }
    return _bgView;
}
- (UIToolbar *)tipView {
    if (!_tipView) {
        _tipView = [[UIToolbar alloc] init];
        _tipView.hidden = YES;
        [_tipView addSubview:self.tipLb];
        if (self.manager.configuration.isWXStyle) {
            _tipView.barTintColor = [UIColor blackColor];
        }
    }
    return _tipView;
}
- (UILabel *)tipLb {
    if (!_tipLb) {
        _tipLb = [[UILabel alloc] init];
        _tipLb.numberOfLines = 0;
        _tipLb.textColor = self.manager.configuration.isWXStyle?[UIColor whiteColor]:self.manager.configuration.themeColor;
        _tipLb.font = [UIFont systemFontOfSize:14];
    }
    return _tipLb;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,self.hx_w - 12 - 50, 50) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[HXPhotoPreviewBottomViewCell class] forCellWithReuseIdentifier:@"DatePreviewBottomViewCellId"];
        }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = 40;
        _flowLayout.itemSize = CGSizeMake(itemWidth, 48);
        _flowLayout.sectionInset = UIEdgeInsetsMake(1, 12, 1, 0);
        _flowLayout.minimumInteritemSpacing = 1;
        _flowLayout.minimumLineSpacing = 1;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
} 
- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:[NSBundle hx_localizedStringForKey:@"完成"] forState:UIControlStateNormal];
        if ([self.manager.configuration.themeColor isEqual:[UIColor whiteColor]]) {
            [_doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        }else {
            [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        }
        if (self.manager.configuration.selectedTitleColor) {
            [_doneBtn setTitleColor:self.manager.configuration.selectedTitleColor forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[self.manager.configuration.selectedTitleColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        }
        
        if (self.manager.configuration.isWXStyle) {
            [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
            _doneBtn.backgroundColor = [UIColor colorWithRed:80/255.0 green:169/255.0 blue:56/255.0 alpha:1];
        }
        else
        {
            _doneBtn.backgroundColor = self.manager.configuration.themeColor;
        }
        
        
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _doneBtn.layer.cornerRadius = 3;
        
        [_doneBtn addTarget:self action:@selector(didDoneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}
- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setTitle:[NSBundle hx_localizedStringForKey:@"编辑"] forState:UIControlStateNormal];
        [_editBtn setTitleColor:self.manager.configuration.themeColor forState:UIControlStateNormal];
        [_editBtn setTitleColor:[self.manager.configuration.themeColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_editBtn addTarget:self action:@selector(didEditBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.hx_size = CGSizeMake(50, 50);
    }
    return _editBtn;
}
@end

@interface HXPhotoPreviewBottomViewCell ()
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) PHImageRequestID requestID;
@end

@implementation HXPhotoPreviewBottomViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.contentView addSubview:self.imageView];
}
- (void)setModel:(HXPhotoModel *)model {
    _model = model;
    
    HXWeakSelf
    if (model.thumbPhoto) {
        self.imageView.image = model.thumbPhoto;
        if (model.networkPhotoUrl) {
            [self.imageView hx_setImageWithModel:model progress:^(CGFloat progress, HXPhotoModel *model) {
                if (weakSelf.model == model) {
                    
                }
            } completed:^(UIImage *image, NSError *error, HXPhotoModel *model) {
                if (weakSelf.model == model) {
                    if (error != nil) {
                    }else {
                        if (image) {
                            weakSelf.imageView.image = image;
                        }
                    }
                }
            }];
        }
    }else {
        self.requestID = [self.model requestThumbImageCompletion:^(UIImage *image, HXPhotoModel *model, NSDictionary *info) {
            if (weakSelf.model == model) {
                weakSelf.imageView.image = image;
            }
        }]; 
    } 
    self.layer.borderWidth = self.selected ? 5 : 0;
    self.layer.borderColor = self.selected ? [self.selectColor colorWithAlphaComponent:0.5].CGColor : nil;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
- (void)setSelectColor:(UIColor *)selectColor {
    if (!_selectColor) {
        self.layer.borderColor = self.selected ? [selectColor colorWithAlphaComponent:0.5].CGColor : nil;
    }
    _selectColor = selectColor;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderWidth = selected ? 5 : 0;
    self.layer.borderColor = selected ? [self.selectColor colorWithAlphaComponent:0.5].CGColor : nil;
}
- (void)cancelRequest {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
}
- (void)dealloc {
    [self cancelRequest];
} 
@end
