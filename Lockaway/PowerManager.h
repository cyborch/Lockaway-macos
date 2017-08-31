//
//  PowerManager.h
//  Lockstep
//
//  Created by Anders Borch on 8/12/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerManager : NSObject

- (BOOL)startSaver;
- (BOOL)startSleep;

@end
