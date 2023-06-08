//
//  OTAMessage.m
//  itest
//
//  Created by fby on 2021/10/29.
//

#import "OTAMessage.h"

@implementation OTAMessage

- (instancetype)initWithId:(int)mid status:(int)status
{
    self = [super init];
    if (self) {
        _mid = mid;
        _status = status;
        _index = -1;
    }
    return self;
}

@end
