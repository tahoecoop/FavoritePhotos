//
//  CustomPhotoCollectionViewCell.m
//  FavoritePhotos
//
//  Created by Benjamin COOPER on 7/30/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import "CustomPhotoCollectionViewCell.h"

@implementation CustomPhotoCollectionViewCell
- (IBAction)onHeartPressed:(UIButton *)sender
{
 //   sender.imageView.image renderingMode = UIImageRenderingModeAlwaysTemplate;

    if (self.imageView.isSelected)
    {
        [sender setTitle:@"Add to Favorites" forState:UIControlStateNormal];
        [self.delegate removeFromFavorites:self];
    }
    else
    {
        [sender setTitle:@"Remove from Favorites" forState:UIControlStateNormal];
        [self.delegate addToFavorites:self];
    }

    self.imageView.isSelected = !self.imageView.isSelected;
}
@end
