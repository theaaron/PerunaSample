//
//  Renderer+Shapes.swift
//  PerunaSample
//
//  Created by aaron on 3/13/25.
//

import MetalKit
import Foundation

extension MetalRenderer {
    
    /// Draws a rectangle on the canvas
    /// - Parameters:
    ///   - x: The x-coordinate of the rectangle's center
    ///   - y: The y-coordinate of the rectangle's center
    ///   - width: The width of the rectangle
    ///   - height: The height of the rectangle
    /// - Note: The rectangle is drawn centered at (x,y)
    func rect(_ x: Float, _ y: Float, _ width: Float, _ height: Float) {
        let rect = PRectangle(
            device: device,
            x: x, y: y,
            width: width, height: height,
            canvasWidth: self.width, canvasHeight: self.height,
            fillColor: self.fillColor,
            strokeColor: self.strokeColor,
            strokeWidth: 3,
            hasStroke: self.hasStroke
        )
        shapes.append(rect)
    }
    
    /// Draws a rectangle on the canvas using named parameters
    /// - Parameters:
    ///   - x: The x-coordinate of the rectangle's center
    ///   - y: The y-coordinate of the rectangle's center
    ///   - width: The width of the rectangle
    ///   - height: The height of the rectangle
    /// - Note: The rectangle is drawn centered at (x,y)
    func rect(x: Float, y: Float, width: Float, height: Float) {
        rect(x, y, width, height)
    }
    
    /// Draws a triangle on the canvas
    /// - Parameters:
    ///   - x1: The x-coordinate of the first vertex
    ///   - y1: The y-coordinate of the first vertex
    ///   - x2: The x-coordinate of the second vertex
    ///   - y2: The y-coordinate of the second vertex
    ///   - x3: The x-coordinate of the third vertex
    ///   - y3: The y-coordinate of the third vertex
    /// - Note: The vertices are connected in order (1->2->3->1)
    func triangle(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float, _ x3: Float, _ y3: Float) {
        let triangle = PTriangle(
            device: device,
            x1: x1, y1: y1,
            x2: x2, y2: y2,
            x3: x3, y3: y3,
            canvasWidth: self.width, canvasHeight: self.height,
            fillColor: self.fillColor,
            strokeColor: self.strokeColor,
            strokeWidth: 3,
            hasStroke: self.hasStroke
        )
        shapes.append(triangle)
    }
    
    /// Draws a triangle on the canvas using named parameters
    /// - Parameters:
    ///   - x1: The x-coordinate of the first vertex
    ///   - y1: The y-coordinate of the first vertex
    ///   - x2: The x-coordinate of the second vertex
    ///   - y2: The y-coordinate of the second vertex
    ///   - x3: The x-coordinate of the third vertex
    ///   - y3: The y-coordinate of the third vertex
    /// - Note: The vertices are connected in order (1->2->3->1)
    func triangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
        triangle(x1, y1, x2, y2, x3, y3)
    }
    
    /// Draws an ellipse on the canvas
    /// - Parameters:
    ///   - x: The x-coordinate of the ellipse's center
    ///   - y: The y-coordinate of the ellipse's center
    ///   - width: The width (horizontal diameter) of the ellipse
    ///   - height: The height (vertical diameter) of the ellipse
    /// - Note: The ellipse is drawn centered at (x,y)
    func ellipse(_ x: Float, _ y: Float, _ width: Float, _ height: Float) {
        let ellipse = PEllipse(
            device: device,
            x: x, y: y,
            width: width, height: height,
            canvasWidth: self.width, canvasHeight: self.height,
            fillColor: self.fillColor,
            strokeColor: self.strokeColor,
            strokeWidth: 3,
            hasStroke: self.hasStroke
        )
        shapes.append(ellipse)
    }
    
    /// Draws an ellipse on the canvas using named parameters
    /// - Parameters:
    ///   - x: The x-coordinate of the ellipse's center
    ///   - y: The y-coordinate of the ellipse's center
    ///   - width: The width (horizontal diameter) of the ellipse
    ///   - height: The height (vertical diameter) of the ellipse
    /// - Note: The ellipse is drawn centered at (x,y)
    func ellipse(x: Float, y: Float, width: Float, height: Float) {
        ellipse(x, y, width, height)
    }
    
    /// Draws a circle on the canvas
    /// - Parameters:
    ///   - x: The x-coordinate of the circle's center
    ///   - y: The y-coordinate of the circle's center
    ///   - diameter: The diameter of the circle
    /// - Note: The circle is drawn centered at (x,y)
    func circle(_ x: Float, _ y: Float, _ diameter: Float) {
        ellipse(x, y, diameter, diameter)
    }
    
    /// Draws a circle on the canvas using named parameters
    /// - Parameters:
    ///   - x: The x-coordinate of the circle's center
    ///   - y: The y-coordinate of the circle's center
    ///   - diameter: The diameter of the circle
    /// - Note: The circle is drawn centered at (x,y)
    func circle(x: Float, y: Float, diameter: Float) {
        circle(x, y, diameter)
    }
    
    /// Draws a line on the canvas
    /// - Parameters:
    ///   - x1: The x-coordinate of the line's start point
    ///   - y1: The y-coordinate of the line's start point
    ///   - x2: The x-coordinate of the line's end point
    ///   - y2: The y-coordinate of the line's end point
    /// - Note: The line color and width are determined by the current stroke settings
    func line(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) {
        let line = PLine(
            device: device,
            x1: x1, y1: y1,
            x2: x2, y2: y2,
            canvasWidth: self.width, canvasHeight: self.height,
            strokeColor: self.strokeColor,
            strokeWidth: 3,
            hasStroke: self.hasStroke
        )
        shapes.append(line)
    }
}
