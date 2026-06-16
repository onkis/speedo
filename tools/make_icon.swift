// make_icon.swift
// Renders the Speedo app icon (big centered numeral + edge tick ring, with the
// four cardinal ticks in the accent color) to PNG.
//
// Run with the full Xcode toolchain:
//   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift tools/make_icon.swift
//
// Tweak the constants below to change the look.

import AppKit

// MARK: - Tunables
let size: CGFloat = 1024
let numeral = "60"
let accent = NSColor(red: 0x30/255.0, green: 0xD1/255.0, blue: 0x58/255.0, alpha: 1) // iOS system green
let bgTop = NSColor(red: 0x0B/255.0, green: 0x0B/255.0, blue: 0x0B/255.0, alpha: 1)
let bgBottom = NSColor.black

let outDir = "speedo/Assets.xcassets/AppIcon.appiconset"

// MARK: - Drawing

/// Renders one icon variant: a big centered numeral with a full ring of edge
/// ticks, the four cardinal (N/E/S/W) ticks drawn in the cardinal color.
func renderIcon(numeralColor: NSColor, tickColor: NSColor, cardinalColor: NSColor) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size), pixelsHigh: Int(size),
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    )!

    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    let center = NSPoint(x: size / 2, y: size / 2)

    // Background gradient (top -> bottom).
    let gradient = NSGradient(starting: bgTop, ending: bgBottom)!
    gradient.draw(in: bounds, angle: -90)

    // Tick ring around the outer edge. Cardinals (top/right/bottom/left) are
    // longer, thicker, and use the accent color.
    let tickCount = 36                 // every 10 degrees
    let outer = size * 0.455
    for i in 0..<tickCount {
        let deg = Double(i) * 360.0 / Double(tickCount)
        let isCardinal = (i * 360 / tickCount) % 90 == 0
        let angle = deg * .pi / 180
        let length = (isCardinal ? size * 0.085 : size * 0.045)
        let inner = outer - length
        let p1 = NSPoint(x: center.x + cos(angle) * inner,
                         y: center.y + sin(angle) * inner)
        let p2 = NSPoint(x: center.x + cos(angle) * outer,
                         y: center.y + sin(angle) * outer)
        let tick = NSBezierPath()
        tick.move(to: p1)
        tick.line(to: p2)
        tick.lineWidth = isCardinal ? size * 0.020 : size * 0.011
        tick.lineCapStyle = .round
        (isCardinal ? cardinalColor : tickColor).setStroke()
        tick.stroke()
    }

    // Numeral — SF Rounded, heavy weight, centered.
    let fontSize = size * 0.42
    let base = NSFont.systemFont(ofSize: fontSize, weight: .heavy)
    let descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
    let font = NSFont(descriptor: descriptor, size: fontSize) ?? base
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: numeralColor,
    ]
    let str = NSAttributedString(string: numeral, attributes: attrs)
    let textSize = str.size()
    // Optically center: nudge up slightly to offset the font's descent space.
    let textRect = NSRect(
        x: (size - textSize.width) / 2,
        y: (size - textSize.height) / 2 + size * 0.01,
        width: textSize.width,
        height: textSize.height
    )
    str.draw(in: textRect)

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

/// Removes the alpha channel (App Store icons must not have alpha). The rendered
/// artwork is already fully opaque — this just emits RGB with no alpha sample.
func strippedAlpha(_ rep: NSBitmapImageRep) -> NSBitmapImageRep {
    guard let cg = rep.cgImage else { fatalError("no cgImage from source rep") }
    let ctx = CGContext(
        data: nil, width: cg.width, height: cg.height,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!
    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
    guard let out = ctx.makeImage() else { fatalError("failed to flatten image") }
    return NSBitmapImageRep(cgImage: out)
}

func write(_ rep: NSBitmapImageRep, to name: String) {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode \(name)")
    }
    let path = "\(outDir)/\(name)"
    do {
        try data.write(to: URL(fileURLWithPath: path))
        print("wrote \(path)")
    } catch {
        fatalError("Failed to write \(path): \(error)")
    }
}

// Default + dark: identical dark artwork, no alpha channel. Minor ticks dim
// white, cardinal ticks in the green accent.
let main = strippedAlpha(renderIcon(
    numeralColor: .white,
    tickColor: NSColor(white: 1, alpha: 0.45),
    cardinalColor: accent
))
write(main, to: "icon-1024.png")
write(main, to: "icon-1024-dark.png")

// Tinted: grayscale, kept with alpha so iOS can apply its tint.
let tinted = renderIcon(
    numeralColor: .white,
    tickColor: NSColor(white: 1, alpha: 0.4),
    cardinalColor: NSColor(white: 1, alpha: 0.85)
)
write(tinted, to: "icon-1024-tinted.png")

print("done")
