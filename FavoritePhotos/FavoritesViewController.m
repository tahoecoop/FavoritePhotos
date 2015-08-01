//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Benjamin COOPER on 7/31/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import "FavoritesViewController.h"
#import "CustomImageView.h"
#import "CustomPhotoCollectionViewCell.h"

@interface FavoritesViewController () <UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CustomPhotoCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *favoritesPhotos;

@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self load];
}

#pragma mark - user defaults

-(NSURL *)pListURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"favoritePhotos.plist"];
}


-(void)save
{
    NSMutableArray *photoData = [NSMutableArray new];

    for (UIImage *image in self.favoritesPhotos)
    {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [photoData addObject:data];
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:photoData forKey:@"images"];
    [userDefaults synchronize];
}



-(void)load
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photoData = [userDefaults objectForKey:@"images"];
    self.favoritesPhotos = [NSMutableArray new];

    for (NSData *data in photoData)
    {
        UIImage *image = [UIImage imageWithData:data];
        [self.favoritesPhotos addObject:image];
    }
    [self.collectionView reloadData];
}

#pragma mark - Collectionview Methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    cell.delegate = self;

    cell.imageView.image = self.favoritesPhotos[indexPath.row];
    cell.imageView.isSelected = YES;

    [cell.heartButton setTitle:@"Remove from Favorites" forState:UIControlStateNormal];

    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return -10;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritesPhotos.count;
}

#pragma mark - Custom Delegate Methods


-(void)removeFromFavorites:(CustomPhotoCollectionViewCell *)currentlylViewedCell
{
    [self.favoritesPhotos removeObject:currentlylViewedCell.imageView.image];
    [self save];
    [self.collectionView reloadData];
}





@end
