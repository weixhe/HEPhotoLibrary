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

@property (nonatomic, strong) UILabel *subTibleLabel;

@end

@implementation HEAlbumListCellCell
- (void)dealloc
{
    self.iconImageView = nil;
    self.titleLabel = nil;
    self.subTibleLabel = nil;
    self.model = nil;
    PhotoLog(@"HEAlbumListCellCell dealloc");
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];

        [self setup];
    }
    return self;
}


- (void)setup {
    
    // 1.iconImageView
    self.iconImageView = [[UIImageView alloc] initWithImage:UIImageFromPhotoBundle(@"defaultphoto")];
    self.iconImageView.frame = CGRectMake(15, 0, 60, 60);
    self.iconImageView.centerY = 40;
    [self.contentView addSubview:self.iconImageView];
    
    CGFloat titleHeight = 40;
    // 2.titleLabel
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + 10, self.iconImageView.top, self.width - self.iconImageView.right - 20, titleHeight)];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLabel];
    
    
    // 3.subTibleLabel
    self.subTibleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + 10, self.titleLabel.bottom, 100, self.iconImageView.height - titleHeight - 4)];
    self.subTibleLabel.font = [UIFont systemFontOfSize:13];
    self.subTibleLabel.textColor = [UIColor lightTextColor];
    [self.contentView addSubview:self.subTibleLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(HEPhotoAlbumModel *)model {
    
    _model = model;
    
    [[HEPhotoTool sharePhotoTool] requestImageForAsset:model.headImageAsset size:CGSizeMake(60 * 3, 60 * 3) resizeMode:PHImageRequestOptionsResizeModeFast complete:^(UIImage *image, NSDictionary *info) {
        self.iconImageView.image = image;
    }];
    
    self.titleLabel.text = LocalizedStringForKey(model.title);
    
    self.subTibleLabel.text = [NSString stringWithFormat:@"%@ %ld %@", LocalizedStringForKey(kTextForTotal), (long)model.count, LocalizedStringForKey(kTextForImageCount)];
}

@end
