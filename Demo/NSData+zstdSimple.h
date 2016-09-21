//
//  NSData+zstdSimple.h
//  xz_test
//
//  Created by Robin on 8/5/16.
//  Copyright © 2016 TendCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (zstdSimple)

+ (NSData *)dataByZSTDSimpleCompressing:(NSData *)aData;
+ (NSData *)dataByZSTDSimpleDeCompressing:(NSData *)aData;

@end
