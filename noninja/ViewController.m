//
//  ViewController.m
//  noninja
//
//  Created by Jeffrey Berthiaume on 12/9/14.
//  Copyright (c) 2014 Pushplay LLC. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    BOOL recording;
}

@property (nonatomic, weak) IBOutlet NSView *videoPreviewView;
@property (nonatomic, weak) IBOutlet NSImageView *imageView;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setUpRecording];
    
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchScreen)
                                                 name:NSApplicationDidChangeScreenParametersNotification
                                               object:nil];
}


- (void) setUpRecording {
    if (!recording) {
        if (_session) {
            [_session stopRunning];
            _session = nil;
        }
        
        [self setupCaptureSession];
        recording = YES;
    }
    
}

- (void) setupCaptureSession {
    NSError *error = nil;
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [_session addInput:input];
    
    dispatch_queue_t queue = dispatch_queue_create("videoCaptureQueue", NULL);
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @( kCVPixelFormatType_32BGRA ) };
    [output setSampleBufferDelegate:self queue:queue];
    
    [_session addOutput:output];
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.name = @"videoPreview";
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = CGRectMake (0, 0, _videoPreviewView.frame.size.width, _videoPreviewView.frame.size.height);
    
    _previewLayer.affineTransform = CGAffineTransformMakeScale (-1,1);
    
    NSLog(@"%f %f", _previewLayer.frame.size.width, _previewLayer.frame.size.height);
    
    //_previewLayer.frame = CGRectMake (0, 0, 400, 200);
    
    [_videoPreviewView setWantsLayer:YES];
    [_videoPreviewView.layer addSublayer:_previewLayer];
    
    [_session setSessionPreset:AVCaptureSessionPresetMedium];
    
    if ([_session canSetSessionPreset:AVCaptureSessionPresetLow]) //Check size based configs are supported before setting them
        [_session setSessionPreset:AVCaptureSessionPresetLow];
    
    [_session startRunning];
}

- (void)windowWillClose:(NSNotification *)notification {
    [_session stopRunning];
}

- (void) switchScreen {
    
    NSWindow *mywindow = self.view.window;
    NSPoint pos;
    pos.x = [[NSScreen mainScreen] frame].size.width - [mywindow frame].size.width ;
    
    pos.y = 0.0f;
    
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    NSScreen *screen;
    while ((screen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [screen frame], NO));
    
    
    pos.x = [screen frame].size.width - [mywindow frame].size.width ;
    
    
    [self.view.window setFrame:CGRectMake(pos.x, pos.y, [mywindow frame].size.width , [mywindow frame].size.height) display:YES];
    
}

@end
