﻿//
//  ITF.m
//  IOS_SDK
//
//  Created by Tzvi on 8/5/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "ITF.h"
#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "PrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"

@implementation ITF

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_width = [[NSArray alloc] initWithObjects:@"2:5", @"4:10", @"6:15", @"2:4", @"4:8", @"6:12", @"2:6", @"3:9", @"4:12", nil];
        array_layout = [[NSArray alloc] initWithObjects:@"No under-bar char + line feed", @"Add under-bar char + line feed", @"No under-bar char + no line feed", @"Add under-bar char + no line feed", nil];
    }
    
    return self;
}

- (void)dealloc
{
    [uiview_block release];
    
    [uitextfield_height release];
    [uitextfield_data release];
    
    [buttonWidth release];
    [buttonLayout release];
    
    [array_width release];
    [array_layout release];
    [buttonBack release];
    [buttonHelp release];
    [buttonPrint release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    uiimageview_barcode.image = [UIImage imageNamed:@"itf.gif"];

    uitextfield_data.delegate = self;
    uitextfield_height.delegate = self;

    selectedWidth  = 0;
    selectedLayout = 0;

    [buttonWidth  setTitle:array_width [selectedWidth]  forState:UIControlStateNormal];
    [buttonLayout setTitle:array_layout[selectedLayout] forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonHelp, buttonLayout, buttonPrint, buttonWidth]];
}

- (void)viewDidUnload
{
    [uiview_block release];
    uiview_block = nil;
    
    [uitextfield_height release];
    uitextfield_height = nil;
    [uitextfield_data release];
    uitextfield_data = nil;
    
    [buttonWidth release];
    buttonWidth = nil;
    [buttonLayout release];
    buttonLayout = nil;
    
    [array_width release];
    array_width = nil;
    [array_layout release];
    array_layout = nil;
    
    [buttonBack release];
    buttonBack = nil;
    [buttonHelp release];
    buttonHelp = nil;
    [buttonPrint release];
    buttonPrint = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backITF
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectWidth:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedWidth = selectedIndex;

        [buttonWidth setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Width" rows:array_width initialSelection:selectedWidth doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectLayout:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedLayout = selectedIndex;

        [buttonLayout setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Layout" rows:array_layout initialSelection:selectedLayout doneBlock:done cancelBlock:cancel origin:sender];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{   
    if ([string isEqualToString:@"\n"] == YES)
    {
        [uitextfield_data resignFirstResponder];
        [uitextfield_height resignFirstResponder];
        return NO;
    }
    
    if (uitextfield_data == textField)
    {
        return YES;
    }
    
    if ([string length] == 0)
    {
        return YES;
    }
    
    if (([string characterAtIndex:0] >= '0') && ([string characterAtIndex:0] <= '9'))
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)showHelp
{
    NSString *title = @"ITF Barcode";
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString: @"<body>\
                <Code>Ascii:</Code> <CodeDef>ESC b ENQ <StandardItalic>n2 n3 n4 d1 ... dk</StandardItalic> RS</CodeDef><br/> \
                <Code>Hex:</Code> <CodeDef>1B 62 04 <StandardItalic>n2 n3 n4 d1 ... dk</StandardItalic> 1E</CodeDef><br/><br/>\
                <TitleBold>Interleaved 2 of 5</TitleBold> represents numbers 0 to 9 and the total digits must be even.  \
                Each pattern can hold 2 digits, one in the black bars and one in the white spaces.  \
                Higher density of characters is possible and with JIS and EAN, and printing to cardboard for distribution \
                has been standardized.\
                </body></html>"];
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:helpVar animated:YES];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (IBAction)printBarcodeITF
{
    [self.view bringSubviewToFront:uiview_block];
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

    NSData *barcodeData = [uitextfield_data.text dataUsingEncoding:NSWindowsCP1252StringEncoding];

    unsigned char *barcodeBytes = (unsigned char*)malloc([barcodeData length]);
    [barcodeData getBytes:barcodeBytes];

    NSString *heightString = uitextfield_height.text;
    int height = [heightString intValue];

    NarrowWideV2   width  = selectedWidth;
    BarCodeOptions layout = selectedLayout;

    [PrinterFunctions PrintCodeITFWithPortname:portName portSettings:portSettings barcodeData:barcodeBytes barcodeDataSize:[barcodeData length] barcodeOptions:layout height:height narrowWide:width];

    free(barcodeBytes);
    
    [self.view sendSubviewToBack:uiview_block];
}

@end
