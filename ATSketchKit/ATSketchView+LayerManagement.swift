//
//  LayerDeletion.swift
//  ATSketchKit
//
//  Created by Arnaud Thiercelin on 11/26/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import Foundation

extension ATSketchView {
	
	func addShapeLayer(shape: UIBezierPath, lineWidth: CGFloat, color: UIColor) {
		let newShapeLayer = ATShapeLayer()
		
		newShapeLayer.path = shape.CGPath
		newShapeLayer.lineWidth = lineWidth
		newShapeLayer.strokeColor = color.CGColor
		newShapeLayer.fillColor = nil
		newShapeLayer.contentsScale = UIScreen.mainScreen().scale

		self.layer.insertSublayer(newShapeLayer, above:  self.topLayer)
		newShapeLayer.setNeedsDisplay()
	}
	
	func findFrontLayerAtPoint(point: CGPoint) -> ATShapeLayer? {
		for layer in self.layer.sublayers! {
			let hitLayer = layer.hitTest(point)
			
			if hitLayer != nil &&
				hitLayer! is ATShapeLayer {
					return hitLayer as? ATShapeLayer
			}
		}
		return nil
	}
	
	/** 
	Returns the number of shape layers within the layer stack
	*/
	public func shapeLayerCount() -> Int {
		var count = 0
		
		for layer in self.layer.sublayers! {
			if layer is ATShapeLayer {
				count++
			}
		}
		return count
	}
	
	func updateTopLayer() {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			
			let smartPath = ATSmartBezierPath(withPoints: self.pointsBuffer)
			let smoothPath = smartPath.smoothPath(20)
			self.topLayer.path = smoothPath.CGPath
			//		self.topLayer.lineWidth = self.currentLineWidth
			
			let strokeColor = (self.currentTool == .Eraser ? self.eraserColor : self.currentColor)
			self.topLayer.strokeColor = strokeColor.CGColor
			self.topLayer.fillColor = nil
		}
	}
	
	func clearTopLayer() {
		self.topLayer.path = nil
	}
}
