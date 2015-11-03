#import <version.h>

static BOOL kEnabled;

@interface CAMFlipButton : UIButton
@end

@interface CAMCameraView : UIView
- (CAMFlipButton *)_flipButton;
@end

@interface PLCameraView : UIView
- (CAMFlipButton *)_flipButton;
@end

@interface CAMBottomBar : UIView
@end

@interface CAMModeDial : UIControl
@end

@interface CAMPreviewContainerView : UIView
@end

%group iOS_9
%hook CAMViewfinderView

- (void)layoutSubviews{
	%orig;
	if(!kEnabled)
		return;
	
	CAMPreviewContainerView *previewContainerView = [self valueForKey:@"_previewContainerView"];
	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
	tapGesture.numberOfTapsRequired = 2;
	tapGesture.numberOfTouchesRequired = 1;
	[previewContainerView addGestureRecognizer:tapGesture];
	[tapGesture release];
	
}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {
 	CAMBottomBar *bBar = MSHookIvar<CAMBottomBar *>(self, "_bottomBar");
	CAMModeDial *dial = MSHookIvar<CAMModeDial *>(bBar, "_modeDial");
	NSInteger *mode = MSHookIvar<NSInteger *>(dial, "_selectedMode");

	if(!kEnabled || (int)(size_t)mode == 2 || (int)(size_t)mode == 3) 						//2 is slo-mo, 3 is pano.
	{	
	}
	else
	{
		CAMFlipButton *flipButton = [[self valueForKey:@"_bottomBar"] valueForKey:@"_flipButton"]; 	//ipad.
		[flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
		
		CAMFlipButton *flipBButton = [[self valueForKey:@"_topBar"] valueForKey:@"_flipButton"]; 		//everything else.
		[flipBButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}
%end

%hook CMKCameraView //Non camera.app

- (void)layoutSubviews{
	%orig;
	if(!kEnabled)
		return;
	
	CAMPreviewContainerView *previewContainerView = [self valueForKey:@"_previewContainerView"];
	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
	tapGesture.numberOfTapsRequired = 2;
	tapGesture.numberOfTouchesRequired = 1;
	[previewContainerView addGestureRecognizer:tapGesture];
	[tapGesture release];
	
}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {
	if(kEnabled)
	{
		CAMFlipButton *flipButton = [[self valueForKey:@"_bottomBar"] valueForKey:@"_flipButton"]; 	//ipad.
		[flipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
		
		CAMFlipButton *flipBButton = [[self valueForKey:@"_topBar"] valueForKey:@"_flipButton"]; 		//everything else.
		[flipBButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}
%end
%end

%group iOS_8
%hook CAMCameraView

- (void)layoutSubviews{
	%orig;
	if(!kEnabled)
		return;
	
	UIView *previewContainerView = MSHookIvar<UIView *>(self, "_previewContainerView");
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
	tapGesture.numberOfTapsRequired = 2;
	tapGesture.numberOfTouchesRequired = 1;
	[previewContainerView addGestureRecognizer:tapGesture];
	[tapGesture release];
	
}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {
	if(kEnabled)
	{
		[[self _flipButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}

%end
%end

%group iOS_7
%hook PLCameraView

- (void)layoutSubviews{
	
	%orig;
	if(!kEnabled)
		return;
	
	UIView *previewContainerView = MSHookIvar<UIView *>(self, "_previewContainerView");
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera:)];
	tapGesture.numberOfTapsRequired = 2;
	tapGesture.numberOfTouchesRequired = 1;
	[previewContainerView addGestureRecognizer:tapGesture];
	[tapGesture release];
	
}

%new
- (void)flipCamera:(UITapGestureRecognizer *)sender {
	if(kEnabled)
	{
		[[self _flipButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}

%end
%end

static void loadPrefs() {
	CFPreferencesAppSynchronize(CFSTR("com.cpdigitaldarkroom.taptapflip"));
	kEnabled = !CFPreferencesCopyAppValue(CFSTR("isEnabled"), CFSTR("com.cpdigitaldarkroom.taptapflip")) ? YES : [(id)CFPreferencesCopyAppValue(CFSTR("isEnabled"), CFSTR("com.cpdigitaldarkroom.taptapflip")) boolValue];
}

%ctor{
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.cpdigitaldarkroom.taptapflip/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	loadPrefs();
	
	if(IS_IOS_BETWEEN(iOS_7_0, iOS_7_1)){
		%init(iOS_7);
	}
	else if(IS_IOS_BETWEEN(iOS_8_0, iOS_8_4)){
		%init(iOS_8);
	}
	else if(IS_IOS_OR_NEWER(iOS_9_0)){
		%init(iOS_9);
	}
}
