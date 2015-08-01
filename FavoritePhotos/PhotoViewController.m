//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Benjamin COOPER on 7/30/15.
//  Copyright (c) 2015 Ben Cooper. All rights reserved.
//

#import "PhotoViewController.h"
#import "CustomPhotoCollectionViewCell.h"
#import "ImageCompare.h"

@interface PhotoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CustomPhotoCollectionViewCellDelegate, UITabBarDelegate>


@property NSString *searchTerm;
@property NSMutableArray *photos;
@property NSMutableArray *favoritesPhotos;

@property NSDictionary *retrievedDatas;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchField;
@property NSMutableArray *favoritePhotoIDs;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;


@end

NSString *const keyInstagram = @"eaeae8c492594ae6bf61f3348a3292ab";

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchTerm = @"ferrari";
    [self fetchPhotos];
    self.favoritesPhotos = [NSMutableArray new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self load];
}

#pragma mark - Fetch Data

-(void)fetchPhotos
{
    NSURL *url;
    if (self.segControl.selectedSegmentIndex == 0)
    {
        url = [NSURL URLWithString: [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?client_id=%@", self.searchTerm, keyInstagram]];
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
         url = [NSURL URLWithString: [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@", self.searchTerm, keyInstagram]];
    }



    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        self.retrievedDatas = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [self parseDatas];
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }]resume];
}

-(void)parseDatas
{
    NSDictionary *dict = self.retrievedDatas[@"data"];
    self.photos = [NSMutableArray new];
//    for (int i = 0; i < 10; i++)
    for (NSDictionary *dictionary in dict)
    {
//        NSDictionary *dictionary = dict;
        NSString *photoURL = dictionary[@"images"][@"standard_resolution"][@"url"];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        ImageCompare *foto = [ImageCompare new];
        foto.image = image;
        foto.photoID = dictionary[@"id"];

        [self.photos addObject:foto];
    }
}

#pragma mark - Collectionview Methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    cell.delegate = self;

    [cell.heartButton setTitle:@"Add to Favorites" forState:UIControlStateNormal];
    cell.heartButton.hidden = NO;

    if (self.photos.count > 0)
    {
        ImageCompare *normalImageCompare = self.photos[indexPath.row];
        cell.imageCompare = normalImageCompare;
        cell.imageView.image = cell.imageCompare.image;

        for (NSNumber *faveID in self.favoritePhotoIDs)
        {
            if ([faveID isEqual: normalImageCompare.photoID])
            {
                [cell.heartButton setTitle:@"Remove from Favorites" forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"funny404"];
        cell.heartButton.hidden = YES;
    }

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.photos.count > 0)
    {
        return 1;
    }
    else if (self.photos.count < 10)
    {
        return self.photos.count;
    }
    else
    {
        return 10;
    }
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return -10;
}


#pragma mark - SearchBar Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchTerm = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [searchBar resignFirstResponder];
    [self fetchPhotos];
}


#pragma mark - Custom Delegate Methods

-(void)addToFavorites:(CustomPhotoCollectionViewCell *)currentlylViewedCell
{
    [self.favoritesPhotos addObject:currentlylViewedCell.imageCompare.image];
    [self.favoritePhotoIDs addObject:currentlylViewedCell.imageCompare.photoID];
    [self save];
}

-(void)removeFromFavorites:(CustomPhotoCollectionViewCell *)currentlylViewedCell
{
    [self.favoritesPhotos removeObject:currentlylViewedCell.imageCompare.image];
    [self.favoritePhotoIDs removeObject:currentlylViewedCell.imageCompare.photoID];
    [self save];
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
    [self.favoritePhotoIDs writeToURL:[self pListURL] atomically:YES];

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
    self.favoritePhotoIDs = [NSMutableArray arrayWithContentsOfURL:[self pListURL]];

    if (self.favoritePhotoIDs == nil)
    {
        self.favoritePhotoIDs = [NSMutableArray new];
    }
}



@end
