// Drops mouse button and drag events while running. Started and killed by
// the ctrl+opt+cmd+t rule in karabiner.json. The event tap goes away with
// the process, so clicks come back if it exits or crashes.
//
// CGEventTap cannot tell the built-in trackpad from an external mouse, so
// external mouse clicks are blocked too.

import ApplicationServices
import Foundation

let blockedTypes: [CGEventType] = [
  .leftMouseDown, .leftMouseUp, .leftMouseDragged,
  .rightMouseDown, .rightMouseUp, .rightMouseDragged,
  .otherMouseDown, .otherMouseUp, .otherMouseDragged,
]
let mask = blockedTypes.reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << $1.rawValue) }

nonisolated(unsafe) var tap: CFMachPort?

let callback: CGEventTapCallBack = { _, type, event, _ in
  // macOS can disable the tap (callback timeout or user input). Re-enable
  // it so clicks do not come back while this process is still running.
  if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
    if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
    return Unmanaged.passUnretained(event)
  }
  return nil
}

let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
if !AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary) {
  FileHandle.standardError.write("nopaw: Accessibility permission is required\n".data(using: .utf8)!)
  exit(1)
}

guard
  let created = CGEvent.tapCreate(
    tap: .cghidEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: mask,
    callback: callback,
    userInfo: nil
  )
else {
  FileHandle.standardError.write("nopaw: failed to create event tap\n".data(using: .utf8)!)
  exit(1)
}
tap = created

let source = CFMachPortCreateRunLoopSource(nil, created, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
CGEvent.tapEnable(tap: created, enable: true)
CFRunLoopRun()
