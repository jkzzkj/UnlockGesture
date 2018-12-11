//
//  CSIGestureUnlockPointView.swift
//  CSIGestureUnlock
//
//  Created by 蒋泽康 on 2018/11/28.
//  Copyright © 2018 手势解锁. All rights reserved.
//

import UIKit

class CSIGestureUnlockPointView: UIImageView {

    /// 选中的图像
    var selectImage: UIImage? = CSIGestureUnlockPointView.drawSelectImage()
    
    /// 默认图像
    var normalImage: UIImage? = CSIGestureUnlockPointView.drawNormalImage()
    
    /// 是否选中
    var selectState: Bool = false {
        didSet {
            self.image = selectState ? self.selectImage : self.normalImage
        }
    }
    
    var pointTag = UnlockPointTag(x: 0, y: 0)
    
    /// 设置默认图像
    ///
    /// - Returns: 非选中状态下的图像
    private class func drawNormalImage() -> UIImage? {
        let scale = UIScreen.main.scale;
        let size = CGSize(width: 50 * scale, height: 50 * scale)
        
        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(1.0 * scale)
            context.addArc(center: CGPoint(x: 25 * scale, y: 25 * scale), radius: 24 * scale, startAngle: CGFloat(Double.pi * 2), endAngle: 0, clockwise: true)
            context.setStrokeColor(UIColor.white.cgColor)
            context.drawPath(using: .stroke)
        }
        
        // 从当前图形上下文中获取一张透明图片
        let img = UIGraphicsGetImageFromCurrentImageContext();
        
        // 关闭图形绘制
        UIGraphicsEndImageContext();
        
        return img ?? nil
        
    }
    
    /// 设置选中图像
    ///
    /// - Returns: 选中状态下的图像
    private class func drawSelectImage() -> UIImage? {
        let scale = UIScreen.main.scale;
        let size = CGSize(width: 50 * scale, height: 50 * scale)
        
        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.addEllipse(in: CGRect(x: 22 * scale, y: 22 * scale, width: 6 * scale, height: 6 * scale))
            context.setFillColor(UIColor.white.cgColor)
            context.fillPath()
            
            context.setLineWidth(1.0 * scale)
            context.addArc(center: CGPoint(x: 25 * scale, y: 25 * scale), radius: 24 * scale, startAngle: CGFloat(Double.pi * 2), endAngle: 0, clockwise: true)
            context.setStrokeColor(UIColor.white.cgColor)
            context.drawPath(using: .stroke)
        }
        
        // 从当前图形上下文中获取一张透明图片
        let img = UIGraphicsGetImageFromCurrentImageContext();
        
        // 关闭图形绘制
        UIGraphicsEndImageContext();
        
        return img ?? nil
        
    }
    
}
