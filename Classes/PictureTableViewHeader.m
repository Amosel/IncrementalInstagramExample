//
//  RWBlackTableViewHeader.m
//  Incremental Instagram Example
//
//  Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//

#import "PictureTableViewHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "UIImageView+AFNetworking.h"


@implementation PictureTableViewHeader
@synthesize backgroundView=_backgroundView;
@synthesize leftLabel=_leftLabel;
@synthesize rightLabel=_rightLabel;
@synthesize imageView = _imageView;

-(void)dealloc
{
    [self.rightLabel removeObserver:self forKeyPath:@"text"];
    [self.leftLabel removeObserver:self forKeyPath:@"text"];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightLabel];
        [self addSubview:self.imageView];

        [self.rightLabel addObserver:self
                          forKeyPath:@"text"
                             options:0
                             context:NULL];
        [self.leftLabel addObserver:self
                         forKeyPath:@"text"
                            options:0
                            context:NULL];

        [self.layer shouldRasterize];
    }
    return self;
}

-(void)setPicture:(Picture *)picture
{
    if (picture) {
        self.leftLabel.text = picture.user.fullname;
        NSURL* iconURL = [NSURL URLWithString:picture.user.profileImageURLString];
        [self.imageView setImageWithURL:iconURL
                       placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
        
        [self setNeedsLayout];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.leftLabel || object == self.rightLabel) {
        [self setNeedsLayout];
    }
}

#pragma mark views

-(UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftLabel.numberOfLines = 1;
        _leftLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        _leftLabel.textAlignment = UITextAlignmentLeft;
        _leftLabel.textColor = [self.class navigationItemBackgroundColor];
        _leftLabel.backgroundColor = [UIColor clearColor];
    }
    return _leftLabel;
}

-(UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightLabel.numberOfLines = 1;
        _rightLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        _rightLabel.textAlignment = UITextAlignmentLeft;
        _leftLabel.textColor = [self.class navigationItemBackgroundColor];
        _rightLabel.backgroundColor = [UIColor clearColor];
    }
    return _rightLabel;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:nil];
    }
    return _imageView;
}

#pragma mark - layout

+(CGFloat)heightForCellWithPicture:(Picture *)picture
{
    return (self.topMargin * 2) + [self iconSize].height;
}

-(void)layoutSubviews
{
    CGFloat xOffset = [self.class leftMargin];
    CGFloat yOffset = [self.class topMargin];
    
    if (self.imageView.image) {
        self.imageView.size = [self.class iconSize];
        self.imageView.top = yOffset;
        self.imageView.left = xOffset;
        xOffset = self.imageView.right + self.class.horizontalSpacing;
    }
    
    [self.leftLabel sizeToFit];
    self.leftLabel.left = xOffset;
    self.leftLabel.top = yOffset + (self.self.leftLabel.font.lineHeight - self.leftLabel.font.ascender);
    
    [self.rightLabel sizeToFit];
    self.rightLabel.right = self.width-7;
    self.rightLabel.top = 0;
    
    self.backgroundView.frame = CGRectMake(0, 0, self.width, self.height+8);

}

-(void)prepareForReuse
{
    [self.imageView cancelImageRequestOperation];
    [self.subviews makeObjectsPerformSelector:@selector(prepareForReuse)];
    self.leftLabel.text = nil;
}

@end
