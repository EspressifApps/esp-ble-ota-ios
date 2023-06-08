//
//  esp_ble_otaUITestsLaunchTests.m
//  esp-ble-otaUITests
//
//  Created by fanbaoying on 2021/10/29.
//

#import <XCTest/XCTest.h>

@interface esp_ble_otaUITestsLaunchTests : XCTestCase

@end

@implementation esp_ble_otaUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
