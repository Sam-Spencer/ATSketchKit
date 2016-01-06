//
//  ATSmartBezierPath+UnistrokeRecognizer.swift
//  ATSketchKit
//
//  Created by Arnaud Thiercelin on 12/29/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//
// This dollar unistroke recognizer implementation was inspired by the work of 
// Chris Miles - https://github.com/chrismiles/CMUnistrokeGestureRecognizer
// Adam Preble - https://github.com/preble/GLGestureRecognizer

import Foundation

extension ATSmartBezierPath {
	
	func recognizedPath() -> (center: CGPoint, angle: CGFloat, path: UIBezierPath) {
		
		let sampleSize = 128 // arbitrary value
		var sample = self.resamplePath(pointsCount: sampleSize)
		let center = self.centroid(sample)
		
		sample = self.translate(sample, deltaX: -center.x, deltaY: -center.y)
		
		let firstPoint = sample.first!
		let firstPointAngle = atan2(firstPoint.y, firstPoint.x)
		
		sample = self.rotate(sample, angle: -firstPointAngle)
		
		
		return (center, firstPointAngle, UIBezierPath())
	}
	
	func resamplePath(pointsCount size: Int) -> [CGPoint] {
		var newSample = [CGPoint]()
		
		for index in 0...self.points.count-1 {
			let computedIndex = (self.points.count - 1) * index / (size - 1)
			let newIndex = 0 < computedIndex ? 0 : computedIndex
			let newPoint = self.points[newIndex]
			
			newSample.append(newPoint)
		}
		
		return newSample
	}
	
	// MARK: - Transformations
	
	func centroid(sample: [CGPoint]) -> CGPoint {
		var xSum: CGFloat = 0
		var ySum: CGFloat = 0;
		let pointCount = CGFloat(sample.count)
		
		for point in sample {
			xSum += point.x
			ySum += point.y
		}
		return CGPointMake(xSum / pointCount, ySum / pointCount)
	}
	
	func translate(sample: [CGPoint], deltaX: CGFloat, deltaY: CGFloat) -> [CGPoint] {
		var newSample = [CGPoint]()
		
		for point in sample {
			let newPoint = CGPointMake(point.x+deltaX, point.y+deltaY)

			newSample.append(newPoint)
		}
		return newSample
	}

	func rotate(sample: [CGPoint], angle: CGFloat) -> [CGPoint] {
		let rotationTransform = CGAffineTransformMakeRotation(angle)
		
		var newSample = [CGPoint]()
		for point in sample {
			let newPoint = CGPointApplyAffineTransform(point, rotationTransform)
			
			newSample.append(newPoint)
		}
		
		return newSample
	}
	
	func scale(sample: [CGPoint], xScale: CGFloat, yScale: CGFloat) -> [CGPoint] {
		let scaleTransform = CGAffineTransformMakeScale(xScale, yScale)
		
		var newSample = [CGPoint]()
		for point in sample {
			let newPoint = CGPointApplyAffineTransform(point, scaleTransform)
			
			newSample.append(newPoint)
		}
		
		return newSample
	}
	
	// MARK: - Distance calculations
	
	func distance(point1: CGPoint, point2: CGPoint) -> CGFloat {
		let deltaX = point1.x - point2.x
		let deltaY = point2.y - point2.y
		
		return sqrt(deltaX * deltaX + deltaY * deltaY)
	}
	
	func pathDistance(path1: [CGPoint], path2: [CGPoint]) -> CGFloat {
		// Normally these should be the same, but just in case we protect against it.
		let count = path1.count > path2.count ? path2.count : path1.count
		var distanceSum: CGFloat = 0
		
		for index in 0...count {
			let point1 = path1[index]
			let point2 = path2[index]
			
			distanceSum += self.distance(point1, point2: point2)
		}
		
		return distanceSum / CGFloat(count)
	}
	
	func distanceAtAngle(path: [CGPoint], template: [CGPoint], angle: CGFloat) -> CGFloat {
		let newPath = self.rotate(path, angle: angle)
		
		return self.pathDistance(newPath, path2: template)
	}
	
	func distanceAtBestAngle(path: [CGPoint], template: [CGPoint]) -> CGFloat {
		var a: CGFloat = -0.25 * CGFloat(M_PI)
		var b: CGFloat = -a
		let threshold: CGFloat = 0.1
		let phi: CGFloat = 0.5 * (-1.0 + sqrt(5.0)) // Golden Ratio
		var x1: CGFloat = phi * a + (1.0 - phi) * b
		var f1: CGFloat = distanceAtAngle(path, template: template, angle: x1)
		var x2: CGFloat = (1.0 - phi) * a + phi * b
		var f2: CGFloat = distanceAtAngle(path, template: template, angle: x2)
		
		while fabs(b - a) > threshold {
			if f1 < f2 {
				b = x2
				x2 = x1
				f2 = f1
				x1 = phi * a + (1.0 - phi) * b
				f1 = distanceAtAngle(path, template: template, angle: x1)
			} else {
				a = x1
				x1 = x2
				f1 = f2
				x2 = (1.0 - phi) * a + phi * b;
				f2 = distanceAtAngle(path, template: template, angle: x2)
			}
		}
		return f1 < f2 ? f1 : f2
	}
	
}