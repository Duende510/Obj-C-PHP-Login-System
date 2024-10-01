#include "Includes/Toast/UIView+Toast.h"
#include "Includes/SCLAlertView/SCLAlertView.h"
#include "Includes/Obfuscate.h"
#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]


NSString *retrieveUDID()
{
  NSString *service = [[NSBundle mainBundle] bundleIdentifier];
  NSString *account = @"UniqueDeviceIdentifier";

  NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
  [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [query setObject:service forKey:(__bridge id)kSecAttrService];
  [query setObject:account forKey:(__bridge id)kSecAttrAccount];
  [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

  CFDataRef dataRef = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&dataRef);

  NSString *udid = nil;

  if (status == errSecSuccess)
  {
    udid = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
  }
  else if (status == errSecItemNotFound)
  {
    udid = [[NSUUID UUID] UUIDString];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [dict setObject:service forKey:(__bridge id)kSecAttrService];
    [dict setObject:account forKey:(__bridge id)kSecAttrAccount];
    [dict setObject:[udid dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
  }

  if (dataRef) CFRelease(dataRef);

    return udid;
}

void showSuccessPopup(NSString *title_, NSString *description_)
{
  SCLAlertView *msgAlert = [[SCLAlertView alloc] initWithNewWindow];

  msgAlert.shouldDismissOnTapOutside = YES;
  msgAlert.customViewColor = UIColorFromHex(0x228B22);
  msgAlert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

  [msgAlert showSuccess:title_ subTitle:description_ closeButtonTitle:nil duration:5.0f];
}

void showErrorPopup(NSString *title_, NSString *description_)
{
  SCLAlertView *msgAlert = [[SCLAlertView alloc] initWithNewWindow];

  msgAlert.shouldDismissOnTapOutside = NO;
  msgAlert.customViewColor = UIColorFromHex(0xD2042D);
  msgAlert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

  [msgAlert showError:title_ subTitle:description_ closeButtonTitle:nil duration:99999999.0f];
}

void showWarningPopup(NSString *title_, NSString *description_)
{
  SCLAlertView *msgAlert = [[SCLAlertView alloc] initWithNewWindow];

  msgAlert.shouldDismissOnTapOutside = NO;
  msgAlert.customViewColor = UIColorFromHex(0xFF5F15);
  msgAlert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

  [msgAlert showWarning:title_ subTitle:description_ closeButtonTitle:nil duration:99999999.0f];
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info)
{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    UITextField *usernameField = [alert addTextField:@"Username"];
    UITextField *passwordField = [alert addTextField:@"Password"];
    usernameField.layer.cornerRadius = 10.0f;
    passwordField.layer.cornerRadius = 10.0f;

    UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
    UIViewController *rootViewController = mainWindow.rootViewController;
    UIView *mainView = rootViewController.view;

    [alert addButton: NSSENCRYPT("Login") actionBlock: ^{
      NSString *username = usernameField.text;
      NSString *password = passwordField.text;
      NSString *deviceIdentifier = retrieveUDID();

      NSString *post = [NSString stringWithFormat:@"username=%@&password=%@&device_identifier=%@", username, password, deviceIdentifier];
      NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
      NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

      NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
      [request setURL:[NSURL URLWithString:@"https://webserver.com/login.php"]];
      [request setHTTPMethod:@"POST"];
      [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
      [request setHTTPBody:postData];

      NSURLSession *session = [NSURLSession sharedSession];
      NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
        if(error)
        {
          dispatch_async(dispatch_get_main_queue(), ^{
            showWarningPopup(@"No Server Connection", @"Closing application...");
            timer(7)
            {
              exit(0);
            });
          });
          return;
        }

        if(data)
        {
          NSError *jsonError;
          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
          NSString *message = json[@"message"];

          if(jsonError)
          {
            dispatch_async(dispatch_get_main_queue(), ^{
              showErrorPopup(@"JSON Parsing Failed", @"Closing application...");
              timer(7)
              {
                exit(0);
              });
            });
            return;
          }

          if ([message isEqualToString:@"Device is banned"])
          {
            dispatch_async(dispatch_get_main_queue(), ^{
              showWarningPopup(@"Your Device Is Banned", @"Closing application...");
              timer(7) {
                exit(0);
              });
            });
          }
          else if ([message isEqualToString:@"Login successful"])
          {
            dispatch_async(dispatch_get_main_queue(), ^{
              showSuccessPopup(@"Welcome to Mod Name", @"Subtitle");
            });
          } else
          {
            // Assuming all other cases are considered login failures
            dispatch_async(dispatch_get_main_queue(), ^{
              showErrorPopup(@"Login Failed", @"Closing application...");
              timer(7)
              {
                exit(0);
              });
            });
          }
        }
    else
    {
      dispatch_async(dispatch_get_main_queue(), ^{
        showErrorPopup(@"Error 404", @"Closing application...");
        timer(7)
        {
          exit(0);
        });
      });
    }
  }];
  [dataTask resume];
}];

    [alert addButton: NSSENCRYPT("Register") actionBlock: ^{
      NSString *username = usernameField.text;
      NSString *password = passwordField.text;

      // Check if either field is empty or contains invalid characters or spaces
      NSCharacterSet *invalidCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
      if ([username length] == 0 || [password length] == 0 || [username rangeOfCharacterFromSet:invalidCharacters].location != NSNotFound || [password rangeOfCharacterFromSet:invalidCharacters].location != NSNotFound || [username containsString:@" "] || [password containsString:@" "])
      {
        dispatch_async(dispatch_get_main_queue(), ^{
          showWarningPopup(@"Invalid Input", @"Closing application...");
          timer(7)
          {
            exit(0);
          });
        });
        return;
      }

      NSString *udid = retrieveUDID();

      NSString *post = [NSString stringWithFormat:@"username=%@&password=%@&device_identifier=%@", username, password, udid];
      NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
      NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

      NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
      [request setURL:[NSURL URLWithString:@"https://webserver.com/register.php"]];
      [request setHTTPMethod:@"POST"];
      [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
      [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
      [request setHTTPBody:postData];

      NSURLSession *session = [NSURLSession sharedSession];
      NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
        if(error)
        {
          dispatch_async(dispatch_get_main_queue(), ^{
            showWarningPopup(@"No Server Connection", @"Closing application...");
            timer(7)
            {
              exit(0);
            });
          });
          return;
        }


        if(data)
        {
          NSError *jsonError;
          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
          if (jsonError)
          {
            dispatch_async(dispatch_get_main_queue(), ^{
              showErrorPopup(@"JSON Parsing Error", @"Closing application...");
            });
            return;
          }

          NSString *message = json[@"message"];

          if ([message isEqualToString:@"Missing parameters."])
          {
            dispatch_async(dispatch_get_main_queue(), ^{
                   showWarningPopup(@"Missing Parameters", @"Closing application...");
               });
          }
          else if ([message isEqualToString:@"Device is banned"])
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                   showWarningPopup(@"Your Device Is Banned", @"Closing application...");
              timer(7) {
                exit(0);
              });
            });
          }
          else if ([message isEqualToString:@"Invalid username or password."])
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                   showWarningPopup(@"Invalid Credentials", @"Closing application...");
               });
          }
          else if ([message isEqualToString:@"Registration successful"])
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                showSuccessPopup(@"Registration Successful", @"Welcome to TweakX");
              });
          }
          else
          {
            dispatch_async(dispatch_get_main_queue(), ^{
              showErrorPopup(@"Registration Failed", @"Closing application...");
              timer(7)
              {
                exit(0);
              });
            });
          }
        }
        else
        {
          dispatch_async(dispatch_get_main_queue(), ^{
            showErrorPopup(@"Error 404", @"Closing application...");
            timer(7)
            {
              exit(0);
            });
          });
        }
      }];

      [dataTask resume];
    }];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor blackColor];
    alert.showAnimationType = SCLAlertViewShowAnimationSlideInToCenter;
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.cornerRadius = 15.0f;
    [alert showInfo:nil title: nil subTitle: nil closeButtonTitle:nil duration:99999999.0f]; // Info
  });
}


%ctor
{
  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
