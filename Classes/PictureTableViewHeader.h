//
//  RWBlackTableViewHeader.h
//  Incremental Instagram Example
//
//  Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//

#import <UIKit/UIKit.h>
#import "Picture.h"

@interface PictureTableViewHeader : UIView
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIView* backgroundView;
@property (nonatomic, retain) UILabel* leftLabel;
@property (nonatomic, retain) UILabel* rightLabel;

+ (CGFloat)heightForCellWithPicture:(Picture *)picture;

-(void) setPicture:(Picture*)picture;

@end
