//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<image_picker_ios/FLTImagePickerPlugin.h>)
#import <image_picker_ios/FLTImagePickerPlugin.h>
#else
@import image_picker_ios;
#endif

#if __has_include(<ultralytics_yolo/YOLOPlugin.h>)
#import <ultralytics_yolo/YOLOPlugin.h>
#else
@import ultralytics_yolo;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
  [YOLOPlugin registerWithRegistrar:[registry registrarForPlugin:@"YOLOPlugin"]];
}

@end
