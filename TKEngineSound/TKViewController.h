//
//  TKViewController.h
//  TKEngineSound
//
//  Created by Timofey Korchagin on 27/07/2012.
//  Copyright (c) 2012 MIPT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectAL.h"
@interface TKViewController : UIViewController
{
    IBOutlet UILabel *label;
}
-(IBAction)pressedOn:(id)sender;
-(IBAction)pressedOff:(id)sender;
@end
