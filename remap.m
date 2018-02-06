// compile and run from the commandline with:
//    clang -fobjc-arc -framework Cocoa  ./remap.m  -o remap
//    sudo ./remap 

#import <Foundation/Foundation.h>
#import <AppKit/NSEvent.h>

typedef CFMachPortRef EventTap;

@interface KeyChanger : NSObject
{
@private
    EventTap _eventTap;
    CFRunLoopSourceRef _runLoopSource;
    CGEventRef _lastEvent;
}
@end

CGEventRef _tapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, KeyChanger* listener);

@implementation KeyChanger

- (BOOL)tapEvents
{
    if (!_eventTap) {
        NSLog(@"Initializing an event tap.");

        _eventTap = CGEventTapCreate(kCGSessionEventTap,
                                     kCGTailAppendEventTap,
                                     kCGEventTapOptionDefault,
                                     CGEventMaskBit(kCGEventKeyDown),
                                     (CGEventTapCallBack)_tapCallback,
                                     (__bridge void *)(self));
        if (!_eventTap) {
            NSLog(@"unable to create event tap. must run as root or add privlidges for assistive devices to this app.");
            return NO;
        }
    }
    CGEventTapEnable(_eventTap, TRUE);

    return [self isTapActive];
}

- (BOOL)isTapActive
{
    return CGEventTapIsEnabled(_eventTap);
}

- (void)listen
{
    if (!_runLoopSource) {
        if (_eventTap) {//dont use [self tapActive]
            _runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault,
                                                           _eventTap, 0);
            // Add to the current run loop.
            CFRunLoopAddSource(CFRunLoopGetCurrent(), _runLoopSource,
                               kCFRunLoopCommonModes);

            NSLog(@"Registering event tap as run loop source.");
            CFRunLoopRun();
        }else{
            NSLog(@"No Event tap in place! You will need to call listen after tapEvents to get events.");
        }
    }
}

- (NSEvent*)getEventCharacter:(NSString*)character event:(NSEvent*) event 
{
    return [NSEvent keyEventWithType:event.type
                                 location:NSZeroPoint
                            modifierFlags:event.modifierFlags
                                timestamp:event.timestamp
                             windowNumber:event.windowNumber
                                  context:event.context
                               characters:character
              charactersIgnoringModifiers:character
                                isARepeat:event.isARepeat
                                  keyCode:event.keyCode];
}

- (NSEvent*)getEventModifier:(int)modifier event:(NSEvent*) event 
{
    return [NSEvent keyEventWithType:event.type
                                 location:NSZeroPoint
                            modifierFlags:modifier
                                timestamp:event.timestamp
                             windowNumber:event.windowNumber
                                  context:event.context
                               characters:@""
              charactersIgnoringModifiers:event.charactersIgnoringModifiers
                                isARepeat:event.isARepeat
                                  keyCode:event.keyCode];
}

- (CGEventRef)processEvent:(CGEventRef)cgEvent
{
    NSEvent* event = [NSEvent eventWithCGEvent:cgEvent];
    int key = [event keyCode];
    int modifier = [event modifierFlags];

    if (key == 11 && modifier == 524352) {
        event = [self getEventCharacter:@"{" event:event];
    }

    else if (key == 45 && modifier == 524352) {
        event = [self getEventCharacter:@"}" event:event];
    }

    else if (key == 3 && modifier == 524352) {
        event = [self getEventCharacter:@"[" event:event];
    }

    else if (key == 5 && modifier == 524352) {
        event = [self getEventCharacter:@"]" event:event];
    }

    else if (key == 9 && modifier == 524352) {
        event = [self getEventCharacter:@"@" event:event];
    }

    else if (key == 12 && modifier == 524352) {
        event = [self getEventCharacter:@"\\" event:event];
    }

    else if (key == 13 && modifier == 524352) {
        event = [self getEventCharacter:@"|" event:event];
    }

    else if (key == 18 && modifier == 524352) {
        event = [self getEventCharacter:@"~" event:event];
    }

    else if (key == 14 && modifier == 524352) {
        event = [self getEventCharacter:@"€" event:event];
    }

    else if (key == 20 && modifier == 524352) {
        event = [self getEventCharacter:@"^" event:event];
    }

    // ctrl->command
    else if (modifier == 262145) {
        event = [self getEventModifier:1048584 event:event];
    }

    // command->ctrl
    else if (modifier == 1048584) {
        event = [self getEventModifier:262145 event:event];
    }

    //NSLog(@"keypress: %d", key);
    //NSLog(@"modifier: %d", modifier);

    _lastEvent = [event CGEvent];
    CFRetain(_lastEvent); // must retain the event. will be released by the system
    return _lastEvent;
}

- (void)dealloc
{
    if (_runLoopSource){
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopCommonModes);
        CFRelease(_runLoopSource);
    }
    if (_eventTap){
        //kill the event tap
        CGEventTapEnable(_eventTap, FALSE);
        CFRelease(_eventTap);
    }
}

@end
CGEventRef _tapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, KeyChanger* listener) {
    //Do not make the NSEvent here.
    //NSEvent will throw an exception if we try to make an event from the tap timout type
    @autoreleasepool {
        if(type == kCGEventTapDisabledByTimeout) {
            NSLog(@"event tap has timed out, re-enabling tap");
            [listener tapEvents];
            return nil;
        }
        if (type != kCGEventTapDisabledByUserInput) {
            return [listener processEvent:event];
        }
    }
    return event;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        KeyChanger* keyChanger = [KeyChanger new];
        [keyChanger tapEvents];
        [keyChanger listen];//blocking call.
    }
    return 0;
}