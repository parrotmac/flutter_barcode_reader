//
// Created by Matthew Smith on 11/7/17.
//

#import "BarcodeScannerViewController.h"
#import <MTBBarcodeScanner/MTBBarcodeScanner.h>


@implementation BarcodeScannerViewController {
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.previewView.frame = self.view.bounds;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [self.view addSubview:_previewView];
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    [_previewView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_previewView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_previewView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_previewView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [_previewView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    if(self.hasTorch) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash On" style:UIBarButtonItemStylePlain target:self action:@selector(toggle)];
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    self.previewView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.height, self.view.frame.size.width);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scanner.isScanning) {
        [self.scanner stopScanning];
    }
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self startScan];
        } else {
          [self.delegate barcodeScannerViewController:self didFailWithErrorCode:@"PERMISSION_NOT_GRANTED"];
          [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isFlashOn]) {
        [self toggleFlash:NO];
    }
}

- (void)startScan {
    NSError *error;
    [self.scanner startScanningWithResultBlock:^(NSArray<AVMetadataMachineReadableCodeObject *> *codes) {
        [self.scanner stopScanning];
         AVMetadataMachineReadableCodeObject *code = codes.firstObject;
        if (code) {
            [self.delegate barcodeScannerViewController:self didScanBarcodeWithResult:code.stringValue];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } error:&error];
}

- (void)cancel {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)updateFlashButton {
    if (!self.hasTorch) {
        return;
    }
    if (self.isFlashOn) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash Off"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(toggle)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash On"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(toggle)];
    }
}

- (void)toggle {
    [self toggleFlash:!self.isFlashOn];
    [self updateFlashButton];
}

- (BOOL)isFlashOn {
    return self.scanner.torchMode == MTBTorchModeOn;
}

- (BOOL)hasTorch {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        return device.hasTorch;
    }
    return false;
}

- (void)toggleFlash:(BOOL)on {
    if(on) {
        self.scanner.torchMode = MTBTorchModeOn;
    } else {
        self.scanner.torchMode = MTBTorchModeOff;
    }
}


@end
