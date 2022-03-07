//
//  Plane.swift
//  DrawingApp
//
//  Created by 백상휘 on 2022/03/03.
//

import Foundation
import UIKit

protocol RectangleViewTapDelegate {
    func changeCurrentSelected(_ rectangle: Rectangle?, parent: UIViewController?, typeOf tap: MainScreenTapType)
}

class Plane: RectangleViewTapDelegate {
    
    let factory = FactoryRectangleProperty()
    var screenDelegate: MainScreenDelegate?
    var planeDelegate: PlaneAdmitDelegate?
    
    private var properties = [RectangleProperty]()
    
    /// ViewController 내에 생성된 뷰 중 현재 선택된 뷰를 Plane 객체가 관리할 것입니다.
    /// 뷰 선택이 가능하도록 하는 이유는 Plane 객체에서 저장된 프로퍼티의 값을 바꾸고
    /// 그에 따라 바뀐 속성을 해당 뷰에 적용하기 위해서입니다.
    var current: Rectangle?
    
    func addProperties(_ model: RectangleProperty) {
        properties.append(model)
    }
    
    func getRectangleCount() -> Int {
        properties.count
    }
    
    func getRectangleProperty(at index: Int) -> RectangleProperty? {
        guard properties.count-1 >= index else {
            return nil
        }
        
        return properties[index]
    }
    
    func hasAnyRectangle(in rect: RectOrigin) -> Bool {
        properties.contains {
            
            let point = $0.point
            let size = $0.size
            
            return point.x >= rect.x
            && point.y >= rect.y
            && point.x+size.width <= rect.x
            && point.y+size.height <= rect.y
        }
    }
    
    // MARK: - Edit properties (ViewContoller use properties)
    
    func setProperty(at index: Int, alpha: Float) {
        guard properties.count-1 >= index else { return }
        properties[index].setAlpha(Double(alpha))
    }
    
    func setProperty(at index: Int, size: RectSize) {
        guard properties.count-1 >= index else { return }
        properties[index].setSize(size)
    }
    
    func setProperty(at index: Int, point: RectOrigin) {
        guard properties.count-1 >= index else { return }
        properties[index].setPoint(point)
    }
    
    // MARK: - MainScreenDelegate implementation
    
    func addRectangle() {
        guard let factoryProperty = screenDelegate?.getScreenViewProperty(), let property = factory.makeRandomView(as: "Subview #\(properties.count)", property: factoryProperty) else {
            return
        }
        properties.append(property)
        screenDelegate?.addRectangle(using: property, index: properties.endIndex-1)
    }
    
    func setRandomColor() -> RectRGBColor? {
        guard let current = current, let color = factory.generateRandomRGBColor() else { return nil }
        
        screenDelegate?.admitColor(
            to: current,
            using: color,
            alpha: properties[current.index].alpha
        )
        return color
    }
    
    func setAlpha(value: Float) {
        guard let current = current else { return }
        screenDelegate?.admitAlpha(to: current, using: value)
    }
    
    // MARK: - RectangleViewTapDelegate implementation
    func changeCurrentSelected(_ rectangle: Rectangle?, parent: UIViewController?, typeOf tap: MainScreenTapType) {
        
        current?.isSelected = false
        current = rectangle
        
        switch tap {
        case .rectangle:
            if let rect = rectangle, properties.count >= rect.index+1 {
                planeDelegate?.admitPlane(property: properties[rect.index])
            }
        case .background:
            planeDelegate?.admitDefault()
        }
    }
}
