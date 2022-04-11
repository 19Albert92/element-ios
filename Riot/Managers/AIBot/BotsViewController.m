//
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MXKAccount.h"

#import "BotsViewController.h"
#import "RecentsDataSource.h"
#import "WebKit/WKWebView.h"
#import "NSString+MD5.h"


#import "FavouritesViewController.h"

#import "GeneratedInterface-Swift.h"

#import "RecentsDataSource.h"

#import "TableViewCellWithCollectionView.h"
#import "RoomCollectionViewCell.h"

#import "MXRoom+Riot.h"

@interface BotsViewController() <WKNavigationDelegate> {
    RecentsDataSource *recentsDataSource;
}

@property (strong, nonatomic) NSString *userID;

@property(strong, nonatomic)WKWebView *webview;
@property(strong, nonatomic)NSString *url;

@end

@implementation BotsViewController

+ (instancetype)instantiate
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BotsViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"BotsViewController"];
    return viewController;
}

- (void)viewDidLoad
{

    self.url = @"https://youtube.com";
    NSURL *urls = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urls];
    self.webview = [[WKWebView alloc] init];
    self.webview.UIDelegate = self;
    self.webview.navigationDelegate = self;
    [self.webview loadRequest:request];
    self.webview.frame = CGRectMake(self.view.frame.origin.x, 85, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.webview];

//    MXKAccount *account = [MXKAccountManager sharedManager].activeAccounts.firstObject;
//
//    [super viewDidLoad];
//
//    self.userID = account.mxCredentials.userId;
//
//    //язык устройства
//    NSString *languages = [[NSLocale preferredLanguages] firstObject];
//
//    NSString *lang2str = [[languages componentsSeparatedByString:@"-"] objectAtIndex:0];
//    NSString *logText = [NSString stringWithFormat:@"this is lang: %@", lang2str];
//    NSLog(logText);
//
//    NSString *urlPath = [NSString stringWithFormat:@"https://qaim.me/%@/assistant", lang2str];
//    NSLog(lang2str);
//    NSURL *url = [NSURL URLWithString:urlPath];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//    //unixtime
//    NSDate *date = [NSDate date];
//    NSTimeInterval ti = [date timeIntervalSince1970];
//
//    //формирование токена
//    NSString *token = [NSString stringWithFormat:@"%fXHD!!@69e%@", ti, self.userID];
//
//    //кодирование в md5
//    NSString *params = token.MD5;
//
//    //параметры авторизации в строке
//    NSMutableString *mutString = [[NSMutableString alloc] initWithString:@"Bearer "];
//    [mutString appendFormat:@"%f", ti];
//    [mutString appendString:@"-"];
//    [mutString appendString:params];
//
//    //параметры авторизации в массив
//    NSDictionary *paramsArray = @{
//        @"Accept-language" : languages,
//        @"Authorization" : mutString
//    };
//
//    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//
//    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
//
//    WKPreferences *preferences = [[WKPreferences alloc] init];
//    preferences.javaScriptEnabled = true;
//    preferences.javaScriptCanOpenWindowsAutomatically = true;
//
//    NSString *userAgent = [NSString stringWithFormat:@"Mozilla/4.0 (compatible; Universion/1.0; iOS; --%@--; +https://qwertynetworks.com)", self.userID];
//
////    [webview.configuration.userContentController addScriptMessageHandler:self name:@"rendering"];
//    webview.customUserAgent = userAgent;
//    webview.configuration.preferences = preferences;
//    webview.navigationDelegate = self;
//
//    [request setAllHTTPHeaderFields:paramsArray];
//
//    [webview loadRequest:request];
//    [self.view addSubview:webview];



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ThemeService.shared.theme applyStyleOnNavigationBar:[AppDelegate theDelegate].masterTabBarController.navigationController.navigationBar];

    [AppDelegate theDelegate].masterTabBarController.tabBar.tintColor = ThemeService.shared.theme.tintColor;

    if (recentsDataSource.recentsDataSourceMode != RecentsDataSourceModeHome)
    {
        // Take the lead on the shared data source.
        [recentsDataSource setDelegate:self andRecentsDataSourceMode:RecentsDataSourceModeHome];
    }
}

- (void)scrollToNextRoomWithMissedNotifications
{
    // Check whether the recents data source is correctly configured.
    if (recentsDataSource.recentsDataSourceMode == RecentsDataSourceModePeople)
    {
        [self scrollToTheTopTheNextRoomWithMissedNotificationsInSection:recentsDataSource.conversationSection];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message = %@", message.body); // полученное сообщение
}

#pragma mark - MasterTabBarItemDisplayProtocol

- (NSString *)masterTabBarItemTitle
{
    return [VectorL10n titleFavourites];
}


@end

