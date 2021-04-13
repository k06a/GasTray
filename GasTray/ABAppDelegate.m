//
//  ABAppDelegate.m
//  GasTray
//
//  Copyright (c) 2016 Anton Bukov <k06aaa@gmail.com>
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ABAppDelegate.h"

@interface ABAppDelegate ()

@property (weak, nonatomic) IBOutlet NSMenu *menu;

@property (strong, nonatomic) NSStatusItem *statusBar;
@property (weak, nonatomic) IBOutlet NSTextFieldCell *slowLabel;
@property (weak, nonatomic) IBOutlet NSTextFieldCell *standardLabel;
@property (weak, nonatomic) IBOutlet NSTextFieldCell *fastLabel;
@property (weak, nonatomic) IBOutlet NSTextFieldCell *instantLabel;
@property (assign, nonatomic) NSInteger selectedIndex;

@end

@implementation ABAppDelegate

- (void)timerFire:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://gasprice.poa.network/"]];
        if (!data) {
            return;
        }
        
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (!json) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusBar.title = [[NSString stringWithFormat:@"%.2f Gwei", [json[@"fast"] floatValue]] stringByReplacingOccurrencesOfString:@".00" withString:@""];
            self.slowLabel.title = [[NSString stringWithFormat:@"%.2f Gwei", [json[@"slow"] floatValue]] stringByReplacingOccurrencesOfString:@".00" withString:@""];
            self.standardLabel.title = [[NSString stringWithFormat:@"%.2f Gwei", [json[@"standard"] floatValue]] stringByReplacingOccurrencesOfString:@".00" withString:@""];
            self.fastLabel.title = [[NSString stringWithFormat:@"%.2f Gwei", [json[@"fast"] floatValue]] stringByReplacingOccurrencesOfString:@".00" withString:@""];
            self.instantLabel.title = [[NSString stringWithFormat:@"%.2f Gwei", [json[@"instant"] floatValue]] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        });
    });
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Configure GUI
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"GasTray";
    self.statusBar.menu = self.menu;
    self.statusBar.highlightMode = YES;
    
    // Configure timer
    NSTimer * timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
}

@end
