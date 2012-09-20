// PictureTableViewCell.h
//  Incremental Instagram Example
//
//  Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//

#import <UIKit/UIKit.h>

@class Picture;

@interface PictureTableViewCell : UITableViewCell

+ (CGFloat)heightForCellWithPicture:(Picture *)picture;
- (void)setPicture:(Picture*)picture;

@end
