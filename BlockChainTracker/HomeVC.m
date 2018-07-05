//
//  HomeVC.m
//  BlockChainTracker
//
//  Created by jogi on 02/07/18.
//  Copyright © 2018 ketanDemo. All rights reserved.
//

#import "HomeVC.h"

@interface HomeVC (){
    NSString * _bitCoinPerUSDStg;
}

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"wss://ws.blockchain.info/inv"]];
    self.navigationItem.title = @"BlockChain";
    [self setViews];
    // create the socket and assign delegate
    self.socket = [PSWebSocket clientSocketWithRequest:request];
    self.socket.delegate = self;
    
    // open socket
    [self.socket open];
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(getBitcoinPrice) userInfo:nil repeats:YES];
    //[self getBitcoinPrice];

}
#pragma Private Methods

- (void)setViews{
    _blockView.layer.cornerRadius = 5.0f;
    _blockView.clipsToBounds = NO;
    _blockView.layer.masksToBounds = NO;
    _blockView.layer.shadowOffset = CGSizeMake(0, 5);
    _blockView.layer.shadowColor = [UIColor grayColor].CGColor;
    _blockView.layer.shadowRadius = 4;
    _blockView.layer.shadowOpacity = 0.3;
    
    _transactionView.layer.cornerRadius = 5.0f;
    _transactionView.clipsToBounds = NO;
    _transactionView.layer.masksToBounds = NO;
    _transactionView.layer.shadowOffset = CGSizeMake(0, 5);
    _transactionView.layer.shadowColor = [UIColor grayColor].CGColor;
    _transactionView.layer.shadowRadius = 4;
    _transactionView.layer.shadowOpacity = 0.3;
}
#pragma mark - PSWebSocketDelegate

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"The websocket handshake completed and is now open!");
    NSString *subscribeTransaction = [NSString stringWithFormat:@"{\"%@\" : \"%@\"}", @"op", @"unconfirmed_sub"];
    NSString *subscribeBlocks = [NSString stringWithFormat:@"{\"%@\" : \"%@\"}", @"op", @"blocks_sub"];
    NSString *PingBlocks = [NSString stringWithFormat:@"{\"%@\" : \"%@\"}", @"op", @"ping_block"];
    _availabilityLbl.text = @"Connected";
   [webSocket send:subscribeTransaction];
   [webSocket send:subscribeBlocks];
   [webSocket send:PingBlocks];
}
- (CGFloat)bitcoinFromSatoshi:(NSString *)satoshi{
    CGFloat bitcoinValue;
    bitcoinValue = [satoshi integerValue]/100000000;
    
    return bitcoinValue;
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([[json valueForKey:@"op"] isEqual:@"utx"]) {
             [self updateTransactionInfoWithDict:json];
        }else{
             [self updateBlockInfoWithDict:json];
        }
    
}
- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"The websocket handshake/connection failed with an error: %@", error);
    
    _availabilityLbl.text = [NSString stringWithFormat:@"Connection Failed due to %@",error];
    _availabilityLbl.backgroundColor = [UIColor redColor];
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    _availabilityLbl.text = @"Disconnected";
    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}
- (void)updateTransactionInfoWithDict:(id)info{
    NSArray*amountAry = [[[info valueForKey:@"x"] valueForKey:@"out"] valueForKey:@"value"];
    if ([self bitcoinFromSatoshi:[amountAry firstObject]] > 0.002) {
        _fetchingTransactionLbl.hidden = YES;
        _transHash.text = [[info valueForKey:@"x"] valueForKey:@"hash"];
        if (_isShowBTCperUSD) {
            CGFloat usd = [self bitcoinFromSatoshi:[amountAry firstObject]]*[_bitCoinPerUSDStg floatValue];
            _transAmount.text = [NSString stringWithFormat:@"$%.02f",usd];
        }else{
            _transAmount.text = [NSString stringWithFormat:@"฿%F",[self bitcoinFromSatoshi:[amountAry firstObject]]];
        }
    }
}
- (void)updateBlockInfoWithDict:(id)info{
    _fetchingBlockLbl.hidden = YES;
    _totalBTCSentLbl.text = [NSString stringWithFormat:@"฿%F",[self bitcoinFromSatoshi:[[info valueForKey:@"x"] valueForKey:@"totalBTCSent"]]];
    _rewardLbl.text =[NSString stringWithFormat:@"%@",[[info valueForKey:@"x"] valueForKey:@"reward"]] ;
    _blockHeightLbl.text =[NSString stringWithFormat:@"%@",[[info valueForKey:@"x"] valueForKey:@"height"]] ;
    _blockHashLbl.text =[NSString stringWithFormat:@"%@",[[info valueForKey:@"x"] valueForKey:@"hash"]] ;
}
- (void)getBitcoinPrice{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://blockchain.info/ticker"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setAllHTTPHeaderFields:nil];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse* ) response;
                                                        if (httpResponse.statusCode == 200) {
                                                           id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            dispatch_async(dispatch_get_global_queue(0, 0), ^{                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                self->_bitCoinPerUSDStg =[NSString stringWithFormat:@"%@",[[json valueForKey:@"USD"] valueForKey:@"buy"]] ;
                                                                CGFloat usd = [self->_bitCoinPerUSDStg floatValue];
                                                                self->_bitcoinPerUSD.text = [NSString stringWithFormat:@"$%.02f BTC/USD",usd];
                                                                });
                                                            });
                                                           
                                                        }
                                                        
                                                    }
                                                }];
    [dataTask resume];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showUSDBtnPressed:(id)sender {
    if (!_isShowBTCperUSD) {
        _isShowBTCperUSD = true;
        [_showBTCPerUSDBtn setTitle:@"Show BTC" forState:UIControlStateNormal];
    }else{
        _isShowBTCperUSD = false;
        [_showBTCPerUSDBtn setTitle:@"Show BTC/USD" forState:UIControlStateNormal];
    }
    
}
@end
