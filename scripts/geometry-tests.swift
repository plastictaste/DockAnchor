import Foundation
import CoreGraphics
func expect(_ value: Bool, _ message: String) { if !value { fatalError(message) } }
let lg = CGRect(x: 0, y: 0, width: 3840, height: 1600)
let below = CGRect(x: 939, y: 1600, width: 1920, height: 1080)
let right = CGRect(x: 3840, y: -223, width: 1440, height: 2560)
let t = RelocationGeometry.target(frame: lg, others: [below, right], edge: .bottom, preferred: 1920)!
expect(t.x > 2859 && t.x < 3840 && t.y == 1599, "Real layout must use exposed right section")
expect(RelocationGeometry.target(frame: lg, others: [], edge: .bottom, preferred: 1920) == CGPoint(x: 1920, y: 1599), "Unblocked preferred position preserved")
expect(RelocationGeometry.target(frame: lg, others: [CGRect(x: 0,y:1600,width:3840,height:100)], edge:.bottom, preferred:1920) == nil, "Fully covered edge rejected")
expect(RelocationGeometry.target(frame: lg, others: [right], edge:.right, preferred:800) == nil, "Right edge blocked")
expect(RelocationGeometry.target(frame: lg, others: [below], edge:.left, preferred:800) == CGPoint(x:1,y:800), "Left edge exposed")
expect(RelocationGeometry.target(frame: lg, others: [below, CGRect(x:0,y:1600,width:1000,height:100)], edge:.bottom, preferred:1920)!.x > 2859, "Overlapping blockers merged by subtraction")
expect(RelocationGeometry.target(frame: lg, others: [], edge:.bottom, preferred:0)!.x == 1920, "Corner target avoided")
print("7 geometry regression checks passed; actual layout target: \(t)")
