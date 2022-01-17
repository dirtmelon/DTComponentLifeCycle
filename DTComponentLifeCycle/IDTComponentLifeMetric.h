//
//  IDTComponentLifeMetric.h
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IDTComponentLifeMetric <NSObject>

@required

- (void)component:(NSString *)name willPerformTask:(NSString *)task;

- (void)component:(NSString *)name didPerformTask:(NSString *)task;

@end

NS_ASSUME_NONNULL_END

