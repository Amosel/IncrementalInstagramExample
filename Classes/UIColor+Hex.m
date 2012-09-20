//
//  UIColor+Hex.m
//  Incremental Instagram Example
//
//  based on three20 http://three20.info
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)colorFromHexString:(NSString *)hexColor {
    CGFloat alpha = 1.0f;
    CGFloat red   = [self colorComponentFrom:hexColor start:1 length: 2];
    CGFloat green = [self colorComponentFrom:hexColor start:3 length: 2];
    CGFloat blue  = [self colorComponentFrom:hexColor start:5 length: 2];
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
