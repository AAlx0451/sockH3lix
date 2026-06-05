//
//  ViewController.m
//  d0ubleH3lix
//
//  Created by tihmstar on 10.12.17.
//  Copyright © 2017 tihmstar.
//

#import "ViewController.h"
#include "jailbreak.h"
#include <sys/utsname.h>
#include <time.h>
#include <errno.h>
#include <sys/sysctl.h>

#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]
extern int (*dsystem)(const char *);
int mccall(uint32_t arg1, uint32_t arg2, uint32_t arg3, uint32_t arg4);
pid_t mpd;

@interface ViewController ()

@end

double uptime(){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return -1.0;
    }
    time_t bsec = boottime.tv_sec, csec = time(NULL);

    return difftime(csec, bsec);
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressFromNotification:) name:@"JB" object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUserInterface];

    struct utsname name;
    uname(&name);

    if (strstr(name.version, "MarijuanARM")){
        self.statusLabel.text = @"";
        [self.gobtn setTitle:@"  run uicache  " forState:UIControlStateNormal];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]){
        [self.gobtn setTitle:@"  Kickstart  " forState:UIControlStateNormal];
    }
}

- (void)setupUserInterface {
    UIView *headerContainer = [[UIView alloc] init];
    headerContainer.translatesAutoresizingMaskIntoConstraints = NO;
    headerContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerContainer];

    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerContainer addSubview:iconImageView];

    UILabel *logoLabel = [[UILabel alloc] init];
    logoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    logoLabel.text = @"H3lix";
    logoLabel.textColor = [UIColor colorWithRed:0.274 green:0.668 blue:0.764 alpha:1.0];
    logoLabel.font = [UIFont fontWithName:@"KohinoorBangla-Regular" size:100] ?: [UIFont systemFontOfSize:100];
    [headerContainer addSubview:logoLabel];

    self.gobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.gobtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.gobtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.760 blue:0.937 alpha:0.665];
    self.gobtn.layer.cornerRadius = 10;
    [self.gobtn setTitle:@"  jailbreak  " forState:UIControlStateNormal];
    [self.gobtn setTitleColor:[UIColor colorWithRed:0.145 green:0.145 blue:0.141 alpha:1.0] forState:UIControlStateNormal];
    self.gobtn.titleLabel.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:37] ?: [UIFont systemFontOfSize:37];
    [self.gobtn addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.gobtn];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.hidden = YES;
    self.statusLabel.text = @"Current status";
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:30] ?: [UIFont systemFontOfSize:30];
    self.statusLabel.numberOfLines = 3;
    self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.statusLabel];

    UILabel *creditsLabel = [[UILabel alloc] init];
    creditsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    creditsLabel.text = @"iOS 10.x jailbreak by sxx";
    creditsLabel.textAlignment = NSTextAlignmentCenter;
    creditsLabel.textColor = [UIColor blackColor];
    creditsLabel.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:17] ?: [UIFont systemFontOfSize:17];
    creditsLabel.numberOfLines = 11;
    [self.view addSubview:creditsLabel];

    id topAnchor = self.view.layoutMarginsGuide.topAnchor;
    id bottomAnchor = self.view.layoutMarginsGuide.bottomAnchor;
    topAnchor = self.topLayoutGuide.bottomAnchor;
    bottomAnchor = self.bottomLayoutGuide.topAnchor;

    [NSLayoutConstraint activateConstraints:@[
        [headerContainer.topAnchor constraintEqualToAnchor:topAnchor constant:61],
        [headerContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [headerContainer.widthAnchor constraintEqualToConstant:310],
        [headerContainer.heightAnchor constraintEqualToConstant:128],
        [iconImageView.widthAnchor constraintEqualToConstant:81],
        [iconImageView.heightAnchor constraintEqualToConstant:81],
        [iconImageView.leadingAnchor constraintEqualToAnchor:headerContainer.leadingAnchor],
        [iconImageView.centerYAnchor constraintEqualToAnchor:headerContainer.centerYAnchor constant:-5.5],
        [logoLabel.leadingAnchor constraintEqualToAnchor:iconImageView.trailingAnchor constant:-8],
        [logoLabel.trailingAnchor constraintEqualToAnchor:headerContainer.trailingAnchor constant:-11.5],
        [logoLabel.centerYAnchor constraintEqualToAnchor:iconImageView.centerYAnchor],
        [logoLabel.topAnchor constraintEqualToAnchor:headerContainer.topAnchor constant:11.5],

        [self.gobtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.gobtn.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [creditsLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:26],
        [creditsLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-22],
        [creditsLabel.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:-14]
    ]];
}

-(void)updateProgressFromNotification:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSString *prog=[sender userInfo][@"JBProgress"];
        NSLog(@"Progress: %@",prog);
        self.statusLabel.text = prog;
        self.statusLabel.hidden = NO;
        self.gobtn.hidden = YES;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)go:(id)sender {
    self.gobtn.enabled = false;
    postProgress(@"looking up offset");
    dispatch_async(jailbreak_queue , ^{
        struct utsname name;
        uname(&name);
        if (strstr(name.version, "MarijuanARM")){
            postProgress(@"running uicache");
            int r = jailbreak_system("(bash -c \"/usr/bin/uicache;killall backboardd\") &");
            if (r!=0) {
                postProgress(@"uicache failed!");
            }else{
                postProgress(@"uicache done!");
            }

            dispatch_sync(dispatch_get_main_queue(), ^(void){
                [self.gobtn setTitle:@"done uicache" forState:UIControlStateNormal];
            });
        }else{
            postProgress(@"running exploit");
            usleep(USEC_PER_SEC/100);
            if (!jailbreak()){
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    [self.gobtn setTitle:@"done jb" forState:UIControlStateNormal];
                });
            }
        }
    });
}
@end
