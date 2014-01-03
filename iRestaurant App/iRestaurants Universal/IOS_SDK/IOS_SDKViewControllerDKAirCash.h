//
//  IOS_SDKViewControllerDKAirCash.h
//  IOS_SDK
//
//  Created by u3237 on 13/06/07.
//
//

#import <UIKit/UIKit.h>
#import "SearchPrinterViewController.h"
#import "CommonTableView.h"

@interface IOS_SDKViewControllerDKAirCash : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, ReturnSelectedCellTextDelegate> {
    SearchPrinterViewController *searchView;
    CommonTableView *commonTableView;
    
    IBOutlet UIView *blockView;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *portNumberButton;
    IBOutlet UIButton *printerTypeButton;
    IBOutlet UIButton *drawerSearchButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *helpButton;
    
    NSArray *functions;
    NSArray *ports;
    NSArray *printerTypes;
    
    int selectedPort;
    int selectedPrinterType;
    
    UITextField *passwordField;
}
@property (retain, nonatomic) IBOutlet UITableView *tableviewFunction;
@property (retain, nonatomic) IBOutlet UITextField *uitextfield_printerPortName;
@property (retain, nonatomic) IBOutlet UITextField *uitextfield_drawerPortName;

- (IBAction)back:(id)sender;
- (IBAction)searchPrinter:(id)sender;
- (IBAction)searchCashDrawer:(id)sender;
- (IBAction)selectPort:(id)sender;
- (IBAction)selectPrinterType:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
