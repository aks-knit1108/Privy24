//
//  PhotoPickerVC.m
//  Privy24
//
//  Created by Amit on 3/2/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "PhotoPickerVC.h"

@interface PhotoPickerVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotoPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selected_images = [[NSMutableDictionary alloc] init];
    self.selected_images_index = [[NSMutableArray alloc] init];
    _assets = [@[] mutableCopy];
    
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)viewWillAppear:(BOOL)animated {

    [self.collectionView reloadData];
    
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    ALAssetsLibrary *assetsLibrary = [PhotoPickerVC defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                
                if([[result valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]){
                    [tmpAssets addObject:result];
                }
            }
        }];
        
        self.assets = tmpAssets;
        [self.collectionView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-
#pragma mark - Table View Delegate Methods

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ASImageCollectionCell *cell = (ASImageCollectionCell *)[collectionView
                                                            dequeueReusableCellWithReuseIdentifier:@"ASImageCollectionCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    
    [cell setImageAsset:asset];
    
    BOOL isContains = [self.selected_images_index containsObject:indexPath];
    
    cell.alphaView.hidden = !isContains;
    cell.checkImage.hidden = !isContains;
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.selected_images_index containsObject:indexPath]){
        [self deselectSelectedImageFromIndexpath:indexPath];
        
    } else {
        [self selectAssestAtIndexPath:indexPath];
    }
    
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout  *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat width = (self.collectionView.bounds.size.width-4)/4.0f;
    return CGSizeMake(width, width);
    
}

-(NSArray *)getSelectedAssets{
    
    return [self.selected_images allValues];
    
}

-(IBAction)onCancel:(id)sender{
    
    
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
        [self.delegate imagePickerControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(IBAction)onDone:(id)sender{
    
    [self finishPickingImages];
    
}

-(void)finishPickingImages{
    
    NSMutableArray *temp = [NSMutableArray new];
    for (NSIndexPath *indexPath in self.selected_images_index) {
        UIImage *image = [self.selected_images objectForKey:indexPath];
        [temp addObject:image];
    }
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImagesWithURL:)]) {
        [self.delegate imagePickerController:self didFinishPickingImagesWithURL:temp];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)selectAssestAtIndexPath:(NSIndexPath* )indexPath
{
    
    ALAsset *asset = self.assets[indexPath.row];
    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
    //[self.selected_images setObject:[[asset defaultRepresentation] url] forKey:indexPath];
    [self.selected_images setObject:image forKey:indexPath];
    [self.selected_images_index addObject:indexPath];
    
    
}

-(void)deselectSelectedImageFromIndexpath:(NSIndexPath *)indexPath
{
    [self.selected_images removeObjectForKey:indexPath];
    [self.selected_images_index removeObject:indexPath];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
