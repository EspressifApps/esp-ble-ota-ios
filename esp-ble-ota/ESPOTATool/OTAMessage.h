//
//  OTAMessage.h
//  itest
//
//  Created by fby on 2021/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTAMessage : NSObject

- (instancetype)initWithId:(int)mid status:(int)status;

@property(assign, nonatomic)int mid;
@property(assign, nonatomic)int status;

@property(assign, nonatomic)int index;

@end

NS_ASSUME_NONNULL_END
