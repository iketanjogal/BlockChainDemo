//
//  HomeVC.h
//  BlockChainTracker
//
//  Created by jogi on 02/07/18.
//  Copyright © 2018 ketanDemo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSWebSocket.h"

@interface HomeVC : UIViewController<PSWebSocketDelegate>{
    
    BOOL _isShowBTCperUSD;
}
@property (weak, nonatomic) IBOutlet UILabel *availabilityLbl;
@property (nonatomic, strong) PSWebSocket *socket;
@property (weak, nonatomic) IBOutlet UIView *blockView;
@property (weak, nonatomic) IBOutlet UILabel *totalBTCSentLbl;
@property (weak, nonatomic) IBOutlet UILabel *rewardLbl;
@property (weak, nonatomic) IBOutlet UILabel *blockHeightLbl;
@property (weak, nonatomic) IBOutlet UILabel *blockHashLbl;
@property (weak, nonatomic) IBOutlet UILabel *fetchingBlockLbl;

@property (weak, nonatomic) IBOutlet UIView *transactionView;
@property (weak, nonatomic) IBOutlet UILabel *transAmount;
@property (weak, nonatomic) IBOutlet UILabel *transHash;
@property (weak, nonatomic) IBOutlet UILabel *bitcoinPerUSD;
@property (weak, nonatomic) IBOutlet UILabel *fetchingTransactionLbl;
@property (weak, nonatomic) IBOutlet UIButton *showBTCPerUSDBtn;

- (IBAction)showUSDBtnPressed:(id)sender;
@end
