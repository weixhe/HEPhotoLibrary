//
//  HEAlbumListCellCell.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/27.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEAlbumListCellCell.h"
#import "HEPhotoTool.h"
#import "HEPhotoConstant.h"

@interface HEAlbumListCellCell ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HEAlbumListCellCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];

        [self setup];
    }
    return self;
}


- (void)setup {
    
    // 1.iconImageView
    self.iconImageView = [[UIImageView alloc] initWithImage:HEPhotoImageFromBundleWithName(@"default_icon.jpg")];
    self.iconImageView.frame = CGRectMake(15, 0, 60, 60);
    self.iconImageView.centerY = 40;
    [self.contentView addSubview:self.iconImageView];
    
    // 2.titleLabel
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + 10, self.iconImageView.top, 100, self.iconImageView.height)];
    [self.contentView addSubview:self.titleLabel];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(HEPhotoAlbumModel *)model {
    
    _model = model;
    
    [[HEPhotoTool sharePhotoTool] requestImageForAsset:model.headImageAsset size:CGSizeMake(40, 40) resizeMode:PHImageRequestOptionsResizeModeFast complete:^(UIImage *image, NSDictionary *info) {
        
        self.iconImageView.image = image;
    }];
    
    self.titleLabel.text = model.title;
}

@end
