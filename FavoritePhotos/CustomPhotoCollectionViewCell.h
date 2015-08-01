//
//  CustomPhotoCollectionViewCell.h
//  FavoritePhotos
//
//  Created by Benjamin COOPER on 7/30/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"
#import "ImageCompare.h"

@protocol CustomPhotoCollectionViewCellDelegate;


@interface CustomPhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet CustomImageView *imageView;
@property BOOL isSelected;

@property (weak, nonatomic) IBOutlet UIButton *heartButton;

@property (weak, nonatomic) id <CustomPhotoCollectionViewCellDelegate> delegate;
@property ImageCompare *imageCompare;

@end


@protocol CustomPhotoCollectionViewCellDelegate <NSObject>

@optional
-(void)addToFavorites: (CustomPhotoCollectionViewCell *)currentlylViewedCell;
-(void)removeFromFavorites: (CustomPhotoCollectionViewCell *)currentlylViewedCell;

@end
