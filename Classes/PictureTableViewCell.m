// PictureTableViewCell.m
//  Incremental Instagram Example
//
//  Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//

#import "PictureTableViewCell.h"

#import "Picture.h"
#import "User.h"
#import "Image.h"

#import "UIImageView+AFNetworking.h"

@implementation PictureTableViewCell

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"] && object == self.imageView) {
        [self performSelectorOnMainThread:@selector(setNeedsLayout)withObject:nil waitUntilDone:NO];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.numberOfLines = 0;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    [self.imageView addObserver:self forKeyPath:@"image" options:0 context:NULL];
    return self;
}

-(void)setPicture:(Picture *)picture
{
    if (picture) {
        NSSet* standard_resolution = [picture.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type == \'standard_resolution\'"]];
        if (standard_resolution.count) {
            Image* image = (Image*)[standard_resolution anyObject];
            self.imageView.frame = CGRectMake(self.class.leftMargin, self.class.topMargin,
                                              image.height.floatValue, image.width.floatValue);
            if (![image data]) {
                NSURL* url = [NSURL URLWithString:image.url];
                [self.imageView setImageWithURL:url];
            }
        }
        [self setNeedsLayout];
    }
}
        
#define maxImageHeight 300

+(CGFloat)heightForCellWithPicture:(Picture *)picture
{    
    CGFloat height = self.class.topMargin * 2.0;
    id maxHeight = [picture.images valueForKeyPath:@"@max.height"];
    if (maxHeight) {
        height += MIN([maxHeight floatValue], maxImageHeight);
    }
    return height;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void)prepareForReuse
{
    [self.imageView cancelImageRequestOperation];
}

@end
