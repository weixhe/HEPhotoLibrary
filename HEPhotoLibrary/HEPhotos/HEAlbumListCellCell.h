//
//  HEAlbumListCellCell.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/27.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  @brief 相簿列表的cell
 */
@class HEPhotoAlbumModel;
@interface HEAlbumListCellCell : UITableViewCell

@property (nonatomic, strong) HEPhotoAlbumModel *model;

@end
