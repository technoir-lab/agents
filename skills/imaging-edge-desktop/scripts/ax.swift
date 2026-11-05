// ax: inspect and drive a running macOS app through the Accessibility API.
//
// Build:  swiftc -O -o <scratch-dir>/ax ax.swift
// The process responsible for the calling shell needs Accessibility access; `ax trusted` names it.
//
// Paths address elements positionally: w<N> is window N, mb is the menu bar, and
// each further .<i> is a child index, e.g. w0.27.5 or mb.2.0.3. Paths shift when
// windows open or close, so look them up again with `tree` or `find` after any change.

import AppKit
import ApplicationServices

let usage = """
usage:
  ax trusted                                 report whether Accessibility access is granted
  ax tree <app> [windows|menubar|all] [depth]
  ax find <app> <text>                       elements whose title/value/description/help/id contains text
  ax info <app> <path>
  ax press <app> <path>                      AXPress
  ax action <app> <path> <AXAction>          e.g. AXCancel, AXConfirm, AXIncrement, AXDecrement
  ax set <app> <path> <value>                set AXValue (number when the current value is numeric)
  ax setattr <app> <path> <attribute> <value>  true/false, number or string, e.g. AXMinimized true
  ax key <app> <key> [cmd] [shift] [ctrl] [opt]  post a key to the app's process (esc, return, tab, a-z, 0-9, ...)
  ax click <app> <x> <y>                     post a left click at screen coordinates to the app's process
<app> is a process name such as Remote, Edit or Viewer, or a pid.
"""

func fail(_ message: String) -> Never {
    FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    exit(1)
}

func errorName(_ e: AXError) -> String {
    switch e {
    case .success: return "ok"
    case .cannotComplete: return "cannotComplete (-25204): the app is busy or a modal dialog/menu opened; read the tree again"
    case .attributeUnsupported: return "attributeUnsupported (-25205)"
    case .actionUnsupported: return "actionUnsupported (-25206)"
    case .invalidUIElement: return "invalidUIElement (-25202): the element is gone; look it up again"
    case .apiDisabled: return "apiDisabled (-25211): Accessibility access is not granted"
    case .illegalArgument: return "illegalArgument (-25201)"
    case .noValue: return "noValue (-25212)"
    default: return "AXError \(e.rawValue)"
    }
}

func attr(_ e: AXUIElement, _ name: String) -> AnyObject? {
    var v: AnyObject?
    return AXUIElementCopyAttributeValue(e, name as CFString, &v) == .success ? v : nil
}

func children(_ e: AXUIElement) -> [AXUIElement] {
    (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? []
}

func text(_ e: AXUIElement, _ name: String) -> String? {
    guard let v = attr(e, name) else { return nil }
    if let s = v as? String { return s.isEmpty ? nil : s }
    if let n = v as? NSNumber { return n.stringValue }
    if CFGetTypeID(v) == AXValueGetTypeID() {
        let av = v as! AXValue
        switch AXValueGetType(av) {
        case .cgPoint:
            var p = CGPoint.zero; AXValueGetValue(av, .cgPoint, &p); return "\(Int(p.x)),\(Int(p.y))"
        case .cgSize:
            var s = CGSize.zero; AXValueGetValue(av, .cgSize, &s); return "\(Int(s.width))x\(Int(s.height))"
        default: return nil
        }
    }
    return nil
}

func actions(_ e: AXUIElement) -> [String] {
    var names: CFArray?
    guard AXUIElementCopyActionNames(e, &names) == .success, let a = names as? [String] else { return [] }
    return a.filter { $0 != "AXShowMenu" && $0 != "AXScrollToVisible" }
}

let arrowGlyphs: [Int: String] = [123: "←", 124: "→", 125: "↓", 126: "↑", 53: "⎋", 36: "↩", 51: "⌫"]

func shortcut(_ e: AXUIElement) -> String? {
    guard let mods = (attr(e, "AXMenuItemCmdModifiers") as? NSNumber)?.intValue else { return nil }
    var key = text(e, "AXMenuItemCmdChar") ?? ""
    // Arrow and other function keys arrive as private-use characters; show their glyph instead.
    let isFunctionKey = key.unicodeScalars.contains { (0xF700...0xF8FF).contains($0.value) }
    if key.isEmpty || isFunctionKey, let vk = (attr(e, "AXMenuItemCmdVirtualKey") as? NSNumber)?.intValue {
        key = arrowGlyphs[vk] ?? ""
    }
    if key.isEmpty { return nil }
    var s = ""
    if mods & 4 != 0 { s += "⌃" }
    if mods & 2 != 0 { s += "⌥" }
    if mods & 1 != 0 { s += "⇧" }
    if mods & 8 == 0 { s += "⌘" }
    return s + key.uppercased()
}

func describe(_ e: AXUIElement) -> String {
    let role = text(e, kAXRoleAttribute) ?? "?"
    var parts = [role + (text(e, kAXSubroleAttribute).map { "/" + $0 } ?? "")]
    for (name, label) in [(kAXTitleAttribute, "title"), (kAXValueAttribute, "value"), (kAXDescriptionAttribute, "desc"),
                          (kAXHelpAttribute, "help"), (kAXIdentifierAttribute, "id")] {
        if let s = text(e, name) {
            if label == "id" && s.hasPrefix("_NS:") { continue }
            parts.append("\(label)=\(String(s.prefix(120)).debugDescription)")
        }
    }
    if let k = shortcut(e) { parts.append("key=\(k)") }
    if let m = text(e, "AXMenuItemMarkChar") { parts.append("mark=\(m)") }
    if let enabled = attr(e, kAXEnabledAttribute) as? Bool, !enabled { parts.append("DISABLED") }
    if role != "AXMenuItem" && role != "AXMenu", let p = text(e, kAXPositionAttribute), let s = text(e, kAXSizeAttribute) {
        parts.append("@\(p) \(s)")
    }
    let acts = actions(e).filter { !(role == "AXMenuItem" && ($0 == "AXPress" || $0 == "AXCancel" || $0 == "AXPick")) }
    if !acts.isEmpty { parts.append("acts=" + acts.joined(separator: ",")) }
    return parts.joined(separator: "  ")
}

// macOS checks Accessibility for the process responsible for this one, usually the
// app or CLI that spawned the shell. Report it, as an .app bundle when it is inside one.
func responsibleBinary() -> String {
    typealias ResponsibleFor = @convention(c) (pid_t) -> pid_t
    var pid = getpid()
    if let symbol = dlsym(dlopen(nil, RTLD_NOW), "responsibility_get_pid_responsible_for_pid") {
        pid = unsafeBitCast(symbol, to: ResponsibleFor.self)(getpid())
    }
    var buffer = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
    guard proc_pidpath(pid, &buffer, UInt32(buffer.count)) > 0 else { return "the process running this shell (pid \(pid))" }
    let path = String(cString: buffer)
    if let range = path.range(of: ".app/", options: .backwards) { return String(path[..<range.lowerBound]) + ".app" }
    return path
}

func resolvePid(_ app: String) -> pid_t {
    if let pid = pid_t(app) { return pid }
    let match = NSWorkspace.shared.runningApplications.first {
        $0.localizedName == app || $0.executableURL?.lastPathComponent == app || $0.bundleURL?.lastPathComponent == app + ".app"
    }
    guard let pid = match?.processIdentifier else { fail("no running app named \(app)") }
    return pid
}

func appElement(_ app: String) -> (AXUIElement, pid_t) {
    let pid = resolvePid(app)
    let element = AXUIElementCreateApplication(pid)
    AXUIElementSetMessagingTimeout(element, 2.0)
    return (element, pid)
}

func roots(_ app: AXUIElement, _ scope: String) -> [(String, AXUIElement)] {
    var result: [(String, AXUIElement)] = []
    if scope == "windows" || scope == "all" {
        for (i, w) in ((attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? []).enumerated() { result.append(("w\(i)", w)) }
    }
    if scope == "menubar" || scope == "all", let mb = attr(app, kAXMenuBarAttribute) {
        result.append(("mb", mb as! AXUIElement))
    }
    return result
}

func resolve(_ app: AXUIElement, _ path: String) -> AXUIElement {
    let parts = path.split(separator: ".").map(String.init)
    guard let head = parts.first else { fail("empty path") }
    var current: AXUIElement
    if head == "mb" {
        guard let mb = attr(app, kAXMenuBarAttribute) else { fail("no menu bar") }
        current = mb as! AXUIElement
    } else if head.hasPrefix("w"), let index = Int(head.dropFirst()) {
        let windows = (attr(app, kAXWindowsAttribute) as? [AXUIElement]) ?? []
        guard index < windows.count else { fail("no window \(head); the app has \(windows.count)") }
        current = windows[index]
    } else {
        fail("path must start with w<N> or mb: \(path)")
    }
    for p in parts.dropFirst() {
        let kids = children(current)
        guard let i = Int(p), i < kids.count else { fail("no child \(p) in \(path)") }
        current = kids[i]
    }
    return current
}

func walk(_ e: AXUIElement, _ path: String, _ depth: Int, _ maxDepth: Int, _ visit: (AXUIElement, String, Int) -> Void) {
    // The Apple menu is system UI and lists the user's recent items; leave it out.
    if text(e, kAXRoleAttribute) == "AXMenuBarItem" && text(e, kAXTitleAttribute) == "Apple" { return }
    visit(e, path, depth)
    if depth >= maxDepth { return }
    for (i, c) in children(e).enumerated() { walk(c, "\(path).\(i)", depth + 1, maxDepth, visit) }
}

let keyCodes: [String: CGKeyCode] = [
    "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9, "b": 11, "q": 12, "w": 13,
    "e": 14, "r": 15, "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25,
    "7": 26, "-": 27, "8": 28, "0": 29, "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35, "return": 36,
    "l": 37, "j": 38, "k": 40, ",": 43, "/": 44, "n": 45, "m": 46, ".": 47, "tab": 48, "space": 49,
    "delete": 51, "esc": 53, "left": 123, "right": 124, "down": 125, "up": 126,
]

var args = Array(CommandLine.arguments.dropFirst())
guard let command = args.first else { print(usage); exit(2) }
args.removeFirst()
func arg(_ i: Int) -> String {
    if i >= args.count { fail(usage) }
    return args[i]
}

switch command {
case "trusted":
    if AXIsProcessTrusted() {
        print("trusted")
    } else {
        print("not trusted: grant Accessibility to \(responsibleBinary())")
    }
case "tree":
    let (app, _) = appElement(arg(0))
    let scope = args.count > 1 ? args[1] : "windows"
    let maxDepth = args.count > 2 ? Int(args[2]) ?? 40 : 40
    for (path, root) in roots(app, scope) {
        walk(root, path, 0, maxDepth) { e, p, d in print(String(repeating: "  ", count: d) + "[\(p)] " + describe(e)) }
    }
case "find":
    let (app, _) = appElement(arg(0))
    let needle = arg(1).lowercased()
    for (path, root) in roots(app, "all") {
        walk(root, path, 0, 40) { e, p, _ in
            let fields = [kAXTitleAttribute, kAXValueAttribute, kAXDescriptionAttribute, kAXHelpAttribute, kAXIdentifierAttribute]
            if fields.contains(where: { (text(e, $0) ?? "").lowercased().contains(needle) }) { print("[\(p)] " + describe(e)) }
        }
    }
case "info":
    let (app, _) = appElement(arg(0))
    print(describe(resolve(app, arg(1))))
case "press", "action":
    let (app, _) = appElement(arg(0))
    let element = resolve(app, arg(1))
    let name = command == "press" ? "AXPress" : arg(2)
    let result = AXUIElementPerformAction(element, name as CFString)
    print("\(name): \(errorName(result))")
    if result != .success && result != .cannotComplete { exit(1) }
case "set", "setattr":
    let (app, _) = appElement(arg(0))
    let element = resolve(app, arg(1))
    let name = command == "set" ? kAXValueAttribute : arg(2)
    let raw = command == "set" ? arg(2) : arg(3)
    let value: CFTypeRef
    if raw == "true" || raw == "false" {
        value = (raw == "true" ? kCFBooleanTrue : kCFBooleanFalse)!
    } else if let n = Double(raw), command == "setattr" || attr(element, name) is NSNumber {
        value = NSNumber(value: n)
    } else {
        value = raw as CFString
    }
    let result = AXUIElementSetAttributeValue(element, name as CFString, value)
    print("\(name)=\(raw): \(errorName(result))")
    if result != .success { exit(1) }
case "key":
    let pid = resolvePid(arg(0))
    let name = arg(1).lowercased()
    guard let code = keyCodes[name] ?? CGKeyCode(name) else { fail("unknown key \(name)") }
    var flags: CGEventFlags = []
    for m in args.dropFirst(2) {
        switch m {
        case "cmd": flags.insert(.maskCommand)
        case "shift": flags.insert(.maskShift)
        case "ctrl": flags.insert(.maskControl)
        case "opt": flags.insert(.maskAlternate)
        default: fail("unknown modifier \(m)")
        }
    }
    let source = CGEventSource(stateID: .hidSystemState)
    for down in [true, false] {
        let event = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down)!
        event.flags = flags
        event.postToPid(pid)
        usleep(50_000)
    }
    print("posted \(name) to \(pid)")
case "click":
    let pid = resolvePid(arg(0))
    guard let x = Double(arg(1)), let y = Double(arg(2)) else { fail(usage) }
    let source = CGEventSource(stateID: .hidSystemState)
    for type in [CGEventType.leftMouseDown, .leftMouseUp] {
        let event = CGEvent(mouseEventSource: source, mouseType: type, mouseCursorPosition: CGPoint(x: x, y: y), mouseButton: .left)!
        event.postToPid(pid)
        usleep(80_000)
    }
    print("clicked \(Int(x)),\(Int(y)) in \(pid)")
default:
    print(usage)
    exit(2)
}
