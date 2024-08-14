//
//  EBAdTableViewController.m
//  ExelbidSample
//
//  Created by HeroK on 2016. 10. 24..
//  Copyright © 2016년 Zionbi. All rights reserved.
//

#import "EBAdTableViewController.h"
#import "EBAdInfo.h"
#import "EBAdSection.h"
#import "EBBannerAdViewController.h"
#import "EBFrontBannerAdViewController.h"
#import "EBDialogAdViewController.h"
#import "EBNativeAdViewController.h"
#import "EBNativeBannerAdViewController.h"
#import "EBNativeAdTableViewController.h"
#import "EBNativeAdCollectionViewController.h"
#import "EBVideoAdViewController.h"
#import "EBNativeVideoAdViewController.h"
#import "EBMediationBannerAdViewController.h"
#import "EBMediationInterstitialAdViewController.h"
#import "EBMediationNativeAdViewController.h"
#import "EBMediationNativeVideoAdViewController.h"
#import "EBMediationBizBoardViewController.h"
#import "EBAdTagViewController.h"
#import "EBMPartnersBannerAdViewController.h"
#import "EBMPartnersNativeAdViewController.h"

#import <Foundation/Foundation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface EBAdTableViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSIndexPath *selectedSavedIndexPath;

@end

@implementation EBAdTableViewController


- (EBAdInfo *)infoAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.sections[indexPath.section] adAtIndex:indexPath.row];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= EB_IOS_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.sections = [EBAdSection adSections];
    
    // 사용자로부터 개인정보 보호에 관한 권한을 요청해야 합니다.
    // 앱 설치 후 첫실행 시 한번만 요청되며, 사용자가 권한에 대해 응답 후 더 이상 사용자에게 권한 요청을 하지 않습니다.
    // 광고식별자를 수집하지 못하는 경우 광고 요청에 대해 응답이 실패할 수 있습니다.
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  
    EBAdInfo *info = [self infoAtIndexPath:(NSIndexPath *)sender];
  
    if ([[segue identifier] isEqualToString:@"Banner"]) {
        EBBannerAdViewController *contoller = (EBBannerAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"FrontBanner"]){
        EBFrontBannerAdViewController *contoller = (EBFrontBannerAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"Native"]){
        EBNativeAdViewController *contoller = (EBNativeAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"Native Banner"]){
        EBNativeBannerAdViewController *contoller = (EBNativeBannerAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"TableView"]){
        EBNativeAdTableViewController *contoller = (EBNativeAdTableViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"CollectionView"]){
        EBNativeAdCollectionViewController *contoller = (EBNativeAdCollectionViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"TableView"]){
        EBNativeAdTableViewController *contoller = (EBNativeAdTableViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"Dialog"]){
        EBDialogAdViewController *contoller = (EBDialogAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"Video"]){
        EBVideoAdViewController *contoller = (EBVideoAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"Native Video"]){
        EBNativeVideoAdViewController *contoller = (EBNativeVideoAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MediationBanner"]){
        EBMediationBannerAdViewController *contoller = (EBMediationBannerAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MediationInterstitial"]){
        EBMediationInterstitialAdViewController *contoller = (EBMediationInterstitialAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MediationNative"]){
        EBMediationNativeAdViewController *contoller = (EBMediationNativeAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MediationNativeVideo"]){
        EBMediationNativeVideoAdViewController *contoller = (EBMediationNativeVideoAdViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MediationBizboardView"]){
        EBMediationBizBoardViewController *contoller = (EBMediationBizBoardViewController *)[segue destinationViewController];
        contoller.info = info;
    }else if ([[segue identifier] isEqualToString:@"AdTag"]){
        EBAdTagViewController *controller = (EBAdTagViewController *)[segue destinationViewController];
        controller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MPartners Banner"]){
        EBMPartnersBannerAdViewController *controller = (EBMPartnersBannerAdViewController *)[segue destinationViewController];
        controller.info = info;
    }else if ([[segue identifier] isEqualToString:@"MPartners Native"]){
        EBMPartnersNativeAdViewController *controller = (EBMPartnersNativeAdViewController *)[segue destinationViewController];
        controller.info = info;
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    EBAdInfo *info = [self infoAtIndexPath:indexPath];
    
    cell.textLabel.text = info.title;
//    cell.detailTextLabel.text = info.ID;
    cell.textLabel.textColor = [UIColor colorWithRed:0.32 green:0.36 blue:0.35 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1];

    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections[section] title];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBAdInfo *info = [self infoAtIndexPath:indexPath];
    
    switch (info.type) {
        case EBAdInfoBanner:
            [self performSegueWithIdentifier:@"Banner" sender:indexPath];
            break;
        case EBAdInfoAllBanner:
            [self performSegueWithIdentifier:@"FrontBanner" sender:indexPath];
            break;
        case EBAdInfoDailBanner:
            [self performSegueWithIdentifier:@"Dialog" sender:indexPath];
            break;
        case EBAdInfoNative:
            [self performSegueWithIdentifier:@"Native" sender:indexPath];
            break;
        case EBAdInfoNativeBanner:
            [self performSegueWithIdentifier:@"Native Banner" sender:indexPath];
            break;
        case EBAdInfoNativeInCollectionView:
            [self performSegueWithIdentifier:@"CollectionView" sender:indexPath];
            break;
        case EBAdInfoNativeTableViewPlacer:
            [self performSegueWithIdentifier:@"TableView" sender:indexPath];
            break;
        case EBAdInfoVideo:
            [self performSegueWithIdentifier:@"Video" sender:indexPath];
            break;
        case EBAdInfoNativeVideo:
            [self performSegueWithIdentifier:@"Native Video" sender:indexPath];
            break;
        case EBAdInfoMediationBanner:
            [self performSegueWithIdentifier:@"MediationBanner" sender:indexPath];
            break;
        case EBAdInfoMediationInterstitial:
            [self performSegueWithIdentifier:@"MediationInterstitial" sender:indexPath];
            break;
        case EBAdInfoMediationNative:
            [self performSegueWithIdentifier:@"MediationNative" sender:indexPath];
            break;
        case EBAdInfoMediationNativeVideo:
            [self performSegueWithIdentifier:@"MediationNativeVideo" sender:indexPath];
            break;
        case EBAdInfoMediationBizboardView:
            [self performSegueWithIdentifier:@"MediationBizboardView" sender:indexPath];
            break;
        case EBAdInfoAdTag:
            [self performSegueWithIdentifier:@"AdTag" sender:indexPath];
            break;
        case EBAdInfoMPartnersBanner:
            [self performSegueWithIdentifier:@"MPartners Banner" sender:indexPath];
            break;
        case EBAdInfoMPartnersNative:
            [self performSegueWithIdentifier:@"MPartners Native" sender:indexPath];
            break;
        default:
            break;
    }
}
@end
