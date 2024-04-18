//
//  EBVideoAdViewController.m
//

#import "EBVideoAdViewController.h"
#import <ExelBidSDK/ExelBidSDK-Swift.h>

@interface EBVideoAdViewController ()<EBVideoDelegate>
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@property (nonatomic, strong) EBVideoManager *interstitial;
@end

@implementation EBVideoAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.showAdButton.hidden = YES;
    self.keywordsTextField.text = self.info.ID;
    [self.loadAdButton.layer setCornerRadius:3.0f];
    [self.showAdButton.layer setCornerRadius:3.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.keywordsTextField endEditing:YES];
    
    self.spinner.hidden = NO;
    self.showAdButton.hidden = YES;
    self.loadAdButton.enabled = NO;
    self.failLabel.hidden = YES;
    
    [EBVideoManager initFullVideoWithIdentifier:self.keywordsTextField.text];
    [EBVideoManager testing:YES];
    [EBVideoManager yob:@"1976"];
    [EBVideoManager gender:@"M"];
    
    [EBVideoManager startWithCompletionHandler:^(EBVideoAdRequest *request, NSError *error) {
        if (error) {
            NSLog(@"Failed to load video ad with error: %@", [error localizedDescription]);
            return;
        }
        
        self.loadAdButton.enabled = YES;
        self.showAdButton.hidden = NO;
    }];
}

- (IBAction)didTapShowButton:(id)sender
{
    [EBVideoManager presentAdWithController:self delegate:self];
    self.showAdButton.hidden = YES;
}

#pragma mark - <EBVideoDelegate>

- (void)videoAdDidLoadWithAdUnitID:(NSString * _Nonnull)adUnitID
{
    self.spinner.hidden = YES;
    self.showAdButton.hidden = NO;
    self.loadAdButton.enabled = YES;
}

- (void)videoAdDidFailToLoadWithAdUnitID:(NSString * _Nonnull)adUnitID error:(NSError * _Nonnull)error
{
    self.failLabel.hidden = NO;
    self.loadAdButton.enabled = YES;
    self.spinner.hidden = YES;
    
}

@end
