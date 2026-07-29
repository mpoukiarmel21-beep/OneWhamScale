// OneWhamScale - Complete Tinder Enhancement Suite
// Version 1.1.0
// Features: Floating Menu, Containers, Location Spoof, Ghost Mode, Fake Camera

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

// ============================================================================
// CONFIGURATION & STATE
// ============================================================================

@interface OWSConfig : NSObject
@property (nonatomic, assign) BOOL locationSpoofEnabled;
@property (nonatomic, assign) BOOL ghostModeEnabled;
@property (nonatomic, assign) BOOL fakeCameraEnabled;
@property (nonatomic, assign) BOOL containerIsolationEnabled;
@property (nonatomic, assign) double spoofedLatitude;
@property (nonatomic, assign) double spoofedLongitude;
@property (nonatomic, strong) NSString *currentContainer;
@property (nonatomic, strong) NSMutableDictionary *containers;
@property (nonatomic, strong) NSString *fakeCameraMediaPath;
@property (nonatomic, strong) AVPlayer *fakeCameraPlayer;
@property (nonatomic, strong) NSArray *availableCities;
+ (instancetype)sharedConfig;
- (void)loadConfig;
- (void)saveConfig;
@end

@implementation OWSConfig

+ (instancetype)sharedConfig {
    static OWSConfig *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[OWSConfig alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        _locationSpoofEnabled = NO;
        _ghostModeEnabled = NO;
        _fakeCameraEnabled = NO;
        _containerIsolationEnabled = NO;
        _spoofedLatitude = 48.8566; // Paris default
        _spoofedLongitude = 2.3522;
        _currentContainer = @"default";
        _containers = [NSMutableDictionary dictionary];
        _availableCities = @[
            @{@"name": @"Paris", @"lat": @48.8566, @"lon": @2.3522},
            @{@"name": @"Lyon", @"lat": @45.7640, @"lon": @4.8357},
            @{@"name": @"Marseille", @"lat": @43.2965, @"lon": @5.3698},
            @{@"name": @"Bordeaux", @"lat": @44.8378, @"lon": @-0.5792},
            @{@"name": @"Toulouse", @"lat": @43.6047, @"lon": @1.4442},
            @{@"name": @"Nice", @"lat": @43.7102, @"lon": @7.2620},
            @{@"name": @"Nantes", @"lat": @47.2184, @"lon": @-1.5536},
            @{@"name": @"Strasbourg", @"lat": @48.5734, @"lon": @7.7521},
            @{@"name": @"Lille", @"lat": @50.6292, @"lon": @3.0573},
            @{@"name": @"New York", @"lat": @40.7128, @"lon": @-74.0060},
            @{@"name": @"London", @"lat": @51.5074, @"lon": @-0.1278},
            @{@"name": @"Tokyo", @"lat": @35.6762, @"lon": @139.6503}
        ];
        [self loadConfig];
    }
    return self;
}

- (void)loadConfig {
    NSString *configPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OneWhamScaleConfig.plist"];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (config) {
        self.locationSpoofEnabled = [config[@"locationSpoofEnabled"] boolValue];
        self.ghostModeEnabled = [config[@"ghostModeEnabled"] boolValue];
        self.fakeCameraEnabled = [config[@"fakeCameraEnabled"] boolValue];
        self.containerIsolationEnabled = [config[@"containerIsolationEnabled"] boolValue];
        self.spoofedLatitude = [config[@"spoofedLatitude"] doubleValue];
        self.spoofedLongitude = [config[@"spoofedLongitude"] doubleValue];
        self.currentContainer = config[@"currentContainer"] ?: @"default";
        self.containers = [NSMutableDictionary dictionaryWithDictionary:config[@"containers"] ?: @{}];
    }
}

- (void)saveConfig {
    NSString *configPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OneWhamScaleConfig.plist"];
    NSDictionary *config = @{
        @"locationSpoofEnabled": @(self.locationSpoofEnabled),
        @"ghostModeEnabled": @(self.ghostModeEnabled),
        @"fakeCameraEnabled": @(self.fakeCameraEnabled),
        @"containerIsolationEnabled": @(self.containerIsolationEnabled),
        @"spoofedLatitude": @(self.spoofedLatitude),
        @"spoofedLongitude": @(self.spoofedLongitude),
        @"currentContainer": self.currentContainer,
        @"containers": self.containers
    };
    [config writeToFile:configPath atomically:YES];
}

@end

// ============================================================================
// FLOATING MENU BUTTON
// ============================================================================

@interface OWSFloatingButton : UIButton
@property (nonatomic, assign) CGPoint initialCenter;
@end

@implementation OWSFloatingButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.95 green:0.3 blue:0.4 alpha:0.9];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowRadius = 4;
        
        UIImage *gearImage = [UIImage systemImageNamed:@"gearshape.fill"];
        [self setImage:gearImage forState:UIControlStateNormal];
        self.tintColor = [UIColor whiteColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        
        [self addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}

- (void)buttonTapped {
    [OWSSettingsPanel showPanel];
}

@end

// ============================================================================
// SETTINGS PANEL
// ============================================================================

@interface OWSSettingsPanel : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;
+ (instancetype)sharedPanel;
- (void)show;
@end

@implementation OWSSettingsPanel

+ (instancetype)sharedPanel {
    static OWSSettingsPanel *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[OWSSettingsPanel alloc] init];
    });
    return shared;
}

+ (void)showPanel {
    OWSSettingsPanel *panel = [self sharedPanel];
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (!window.rootViewController) return;
    [window.rootViewController presentViewController:panel animated:YES completion:nil];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Fermer" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.view.bounds.size.width - 80, 50, 70, 30);
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    self.sections = @[
        @{
            @"title": @"Localisation",
            @"rows": @[
                @{@"title": @"Spoof GPS", @"type": @"switch", @"key": @"locationSpoofEnabled"},
                @{@"title": @"Choisir ville", @"type": @"action", @"key": @"selectCity"}
            ]
        },
        @{
            @"title": @"Mode Ghost",
            @"rows": @[
                @{@"title": @"Activer Ghost Mode", @"type": @"switch", @"key": @"ghostModeEnabled"}
            ]
        },
        @{
            @"title": @"Caméra",
            @"rows": @[
                @{@"title": @"Fake Camera", @"type": @"switch", @"key": @"fakeCameraEnabled"},
                @{@"title": @"Sélectionner vidéo", @"type": @"action", @"key": @"selectVideo"}
            ]
        },
        @{
            @"title": @"Conteneurs",
            @"rows": @[
                @{@"title": @"Isolation comptes", @"type": @"switch", @"key": @"containerIsolationEnabled"},
                @{@"title": @"Gérer conteneurs", @"type": @"action", @"key": @"manageContainers"}
            ]
        }
    ];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window.rootViewController presentViewController:self animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section][@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    NSDictionary *row = self.sections[indexPath.section][@"rows"][indexPath.row];
    cell.textLabel.text = row[@"title"];
    
    if ([row[@"type"] isEqualToString:@"switch"]) {
        UISwitch *toggle = [[UISwitch alloc] init];
        NSString *key = row[@"key"];
        OWSConfig *config = [OWSConfig sharedConfig];
        
        if ([key isEqualToString:@"locationSpoofEnabled"]) toggle.on = config.locationSpoofEnabled;
        else if ([key isEqualToString:@"ghostModeEnabled"]) toggle.on = config.ghostModeEnabled;
        else if ([key isEqualToString:@"fakeCameraEnabled"]) toggle.on = config.fakeCameraEnabled;
        else if ([key isEqualToString:@"containerIsolationEnabled"]) toggle.on = config.containerIsolationEnabled;
        
        [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        toggle.accessibilityIdentifier = key;
        cell.accessoryView = toggle;
    }
    
    return cell;
}

- (void)switchChanged:(UISwitch *)sender {
    NSString *key = sender.accessibilityIdentifier;
    OWSConfig *config = [OWSConfig sharedConfig];
    
    if ([key isEqualToString:@"locationSpoofEnabled"]) config.locationSpoofEnabled = sender.on;
    else if ([key isEqualToString:@"ghostModeEnabled"]) config.ghostModeEnabled = sender.on;
    else if ([key isEqualToString:@"fakeCameraEnabled"]) config.fakeCameraEnabled = sender.on;
    else if ([key isEqualToString:@"containerIsolationEnabled"]) config.containerIsolationEnabled = sender.on;
    
    [config saveConfig];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

@end

// ============================================================================
// LOCATION SPOOFING HOOKS
// ============================================================================

%hook CLLocationManager

- (void)startUpdatingLocation {
    if ([OWSConfig sharedConfig].locationSpoofEnabled) {
        CLLocation *fakeLocation = [[CLLocation alloc] initWithLatitude:[OWSConfig sharedConfig].spoofedLatitude
                                                             longitude:[OWSConfig sharedConfig].spoofedLongitude];
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [self.delegate locationManager:self didUpdateLocations:@[fakeLocation]];
        }
        return;
    }
    %orig;
}

- (CLLocation *)location {
    if ([OWSConfig sharedConfig].locationSpoofEnabled) {
        return [[CLLocation alloc] initWithLatitude:[OWSConfig sharedConfig].spoofedLatitude
                                          longitude:[OWSConfig sharedConfig].spoofedLongitude];
    }
    return %orig;
}

%end

// ============================================================================
// GHOST MODE HOOKS
// ============================================================================

%hook TinderAPI

- (void)updateUserPresence:(BOOL)online {
    if ([OWSConfig sharedConfig].ghostModeEnabled) {
        %orig(NO);
    } else {
        %orig;
    }
}

- (void)sendTypingIndicator {
    if (![OWSConfig sharedConfig].ghostModeEnabled) {
        %orig;
    }
}

%end

// ============================================================================
// FAKE CAMERA HOOKS (Photo + Video)
// ============================================================================

%hook AVCaptureDevice

+ (AVCaptureDevice *)defaultDeviceWithMediaType:(AVMediaType)mediaType {
    if ([OWSConfig sharedConfig].fakeCameraEnabled && [mediaType isEqualToString:AVMediaTypeVideo]) {
        return nil;
    }
    return %orig;
}

%end

%hook AVCaptureSession

- (BOOL)canAddInput:(AVCaptureInput *)input {
    if ([OWSConfig sharedConfig].fakeCameraEnabled && [input isKindOfClass:[AVCaptureDeviceInput class]]) {
        AVCaptureDeviceInput *deviceInput = (AVCaptureDeviceInput *)input;
        if ([deviceInput.device hasMediaType:AVMediaTypeVideo]) {
            return NO;
        }
    }
    return %orig;
}

- (void)startRunning {
    if ([OWSConfig sharedConfig].fakeCameraEnabled) {
        // Inject fake video frames
        [self injectFakeVideoFrames];
        return;
    }
    %orig;
}

- (void)injectFakeVideoFrames {
    OWSConfig *config = [OWSConfig sharedConfig];
    NSString *mediaPath = config.fakeCameraMediaPath;
    
    if (!mediaPath) return;
    
    // Get media type (photo or video)
    BOOL isVideo = [mediaPath.pathExtension.lowercaseString isEqualToString:@"mp4"] || 
                   [mediaPath.pathExtension.lowercaseString isEqualToString:@"mov"];
    
    if (isVideo) {
        // Loop video file
        NSURL *videoURL = [NSURL fileURLWithPath:mediaPath];
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetTrack *track = [asset.tracks firstObject];
        
        if (track) {
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            // Loop video
            [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                              object:item
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                [item seekToTime:kCMTimeZero];
                [player play];
            }];
            
            [player play];
            config.fakeCameraPlayer = player;
        }
    }
    // Photo mode: handled by OWSCameraPreview overlay
}

%end

// ============================================================================
// CONTAINER ISOLATION HOOKS
// ============================================================================

%hook NSUserDefaults

- (instancetype)initWithSuiteName:(NSString *)suiteName {
    if ([OWSConfig sharedConfig].containerIsolationEnabled) {
        NSString *container = [OWSConfig sharedConfig].currentContainer;
        NSString *isolatedSuite = [NSString stringWithFormat:@"%@_%@", suiteName ?: @"default", container];
        return %orig(isolatedSuite);
    }
    return %orig;
}

%end

%hook NSFileManager

- (NSString *)URLForDirectory:(NSSearchPathDirectory)directory 
                     inDomain:(NSSearchPathDomainMask)domain 
            appropriateForURL:(NSURL *)url 
                       create:(BOOL)shouldCreate 
                        error:(NSError **)error {
    if ([OWSConfig sharedConfig].containerIsolationEnabled) {
        NSString *container = [OWSConfig sharedConfig].currentContainer;
        NSString *path = %orig;
        if (path) {
            NSString *isolatedPath = [path stringByAppendingPathComponent:container];
            if (shouldCreate) {
                [[NSFileManager defaultManager] createDirectoryAtPath:isolatedPath 
                                          withIntermediateDirectories:YES 
                                                           attributes:nil 
                                                                error:error];
            }
            return isolatedPath;
        }
    }
    return %orig;
}

%end

// ============================================================================
// INITIALIZATION
// ============================================================================

%ctor {
    @autoreleasepool {
        // Initialize config
        [OWSConfig sharedConfig];
        
        // Wait for app to be ready
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Create floating button
            OWSFloatingButton *button = [[OWSFloatingButton alloc] initWithFrame:CGRectMake(20, 100, 50, 50)];
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            [window addSubview:button];
        });
    }
}
