//
//  CSIGestureUnlockView.swift
//  CSIGestureUnlock
//
//  Created by 蒋泽康 on 2018/11/28.
//  Copyright © 2018 csizg. All rights reserved.
//

import UIKit

struct UnlockPointTag {
    var x: Int
    var y: Int
}

//异常类型
enum CSIUnlockErrorType {
    ///比最小需要点的个数少
    case lessUnlockNum
}

class CSIGestureUnlockView: UIView {
    
    //MARK: - 属性设置
    /// 每个边上点的个数
    @IBInspectable var linePoint: Int = 3 {
        didSet {
            if linePoint >= 3 {
                self.configUI()
            } else {
                linePoint = 3
            }
        }
    }
    
    /// 每个点的图片(默认状态)
    @IBInspectable var pointImage: UIImage? {
        didSet {
            self.configUI()
        }
    }
    
    /// 每个点的图片(画线状态)
    @IBInspectable var pointSelectImage: UIImage? {
        didSet {
            self.configUI()
        }
    }
    
    /// 画线的颜色
    @IBInspectable var lineColor: UIColor = .white {
        didSet {
            self.configUI()
        }
    }
    
    /// 画线的宽度
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            self.configUI()
        }
    }
    
    /// 最小需要连线的个数
    @IBInspectable var minUnlockCount: Int = 3 {
        didSet {
            self.configUI()
        }
    }
    
    /// 数值是否按比例设置 以375宽度为标准
    @IBInspectable var scaleEnable: Bool = true {
        didSet {
            self.configUI()
        }
    }
    
    /// 每个点的大小
    @IBInspectable var pointSize: CGFloat = 50 {
        didSet {
            self.configUI()
        }
    }
    
    /// 设置边界无内容范围
    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            self.configUI()
        }
    }
    
    /// 代理事件
    var delegate: CSIGestureUnlockViewDelegate?
    
    /// 图像矩阵数组[[0, 1, 2], [0, 1, 2], [0, 1, 2]]横向
    private var pointImageArray: [[CSIGestureUnlockPointView]] = []
    
    /// 选中的图像矩阵
    private var selectPointArray: [UnlockPointTag] = []
    
    //路径
    private var path:UIBezierPath = UIBezierPath()
    
    //当前手指所在点
    var fingurePoint:CGPoint!

    //MARK: - 重写初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: - 扩大手势范围 解决当前存在超出范围不响应
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if selectPointArray.count > 0 {
            return true
        }
        return super.point(inside: point, with: event)
    }
    
    //MARK: - 界面frame改变 相应改变subViewFrame
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.configUI()
    }
    
    //MARK: - 设置界面效果
    /// 设置界面效果
    private func configUI() {
        if self.superview != nil {
            for array in pointImageArray {
                for item in array {
                    item.removeFromSuperview()
                }
            }
            
            path.lineJoinStyle = .round
            
            pointImageArray.removeAll()
            
            let scale = scaleEnable ? UIScreen.main.bounds.width / 375.0 : 1
            let realPointSize = CGSize(width: pointSize * scale, height: pointSize * scale)
            
            var realContentInset = UIEdgeInsets(top: contentInsets.top * scale, left: contentInsets.left * scale, bottom: contentInsets.bottom * scale, right: contentInsets.right * scale)
            
            if realContentInset == .zero {
                if self.frame.width > self.frame.height {
                    realContentInset = UIEdgeInsets(top: 0, left: (self.frame.width - self.frame.height) / 2, bottom: 0, right: (self.frame.width - self.frame.height) / 2)
                } else {
                    realContentInset = UIEdgeInsets(top: (self.frame.height - self.frame.width) / 2, left: 0, bottom: (self.frame.height - self.frame.width) / 2, right: 0)
                }
                
            }
            
            let drawWidth = (self.frame.size.width - realContentInset.left - realContentInset.right) > (self.frame.size.height - realContentInset.top - realContentInset.bottom) ? (self.frame.size.height - realContentInset.top - realContentInset.bottom) : (self.frame.size.width - realContentInset.left - realContentInset.right)
            let realSpacing = (drawWidth - realPointSize.width * CGFloat(linePoint)) / CGFloat(linePoint - 1)
            
            for x in 0..<linePoint {
                var array: [CSIGestureUnlockPointView] = []
                for y in 0..<linePoint {
                    let frame = CGRect(x: (realPointSize.width + realSpacing) * CGFloat(y) + realContentInset.left, y: (realPointSize.height + realSpacing) * CGFloat(x) + realContentInset.top, width: realPointSize.width, height: realPointSize.height)
                    let view = CSIGestureUnlockPointView(frame: frame)
                    view.pointTag = UnlockPointTag(x: x, y: y)
                    view.selectState = false
                    if let normalImage = self.pointImage {
                        view.normalImage = normalImage
                    }
                    if let selectImage = self.pointSelectImage {
                        view.selectImage = selectImage
                    }
                    for tag in selectPointArray {
                        if tag.x == view.pointTag.x && tag.y == view.pointTag.y {
                            view.selectState = true
                            break
                        }
                    }
                    self.addSubview(view)
                    array.append(view)
                }
                pointImageArray.append(array)
            }
            
            
        }
    }
    
    ///MARK: - 恢复未选择手势样式
    /// 恢复未选择手势样式
    func resetNoSelectUI() {
        for array in pointImageArray {
            for view in array {
                view.selectState = false
            }
        }
        
        selectPointArray.removeAll()
        path.removeAllPoints()
        setNeedsDisplay()
        fingurePoint = CGPoint.zero
    }
    
    //MARK: - 绘制
    override func draw(_ rect: CGRect)
    {
        self.path.removeAllPoints()
        for (index, tag) in selectPointArray.enumerated()
        {
            let view = pointImageArray[tag.x][tag.y]
            let centerPoint = view.center
            if index == 0
            {
                path.move(to: centerPoint)
            }
            else
            {
                path.addLine(to: centerPoint)
            }
            
        }
        
        //让画线跟随手指
        if self.fingurePoint != CGPoint.zero && self.selectPointArray.count > 0
        {
            path.addLine(to: self.fingurePoint)
        }
        
        //设置线的颜色
        let color = self.lineColor
        color.set()
        path.lineWidth = self.lineWidth
        path.stroke()
    }
    
    //MARK: - 手势操作重写
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //每次点击移除所有存储过的点，重新统计
        selectPointArray.removeAll()
        
        for array in pointImageArray {
            for view in array {
                view.selectState = false
            }
        }
        
        touchChanged(touch: touches.first!)
        
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        touchChanged(touch: touches.first!)
    }
    
    func touchChanged(touch:UITouch)
    {
        let point = touch.location(in: self)
        fingurePoint = point
        for view in subviews
        {
            if view.isKind(of: CSIGestureUnlockPointView.self) && view.frame.contains(point) && !selectPointArray.contains(where: { (tags) -> Bool in
                if let tempImageView = view as? CSIGestureUnlockPointView {
                    if (tags.x == tempImageView.pointTag.x && tags.y == tempImageView.pointTag.y) {
                        return true
                    }
                }
                return false
            })
            {
                if let tempImageView = view as? CSIGestureUnlockPointView {
                    //记录已经走过的点
                    selectPointArray.append(tempImageView.pointTag)
                    //设置按钮的背景色
                    tempImageView.selectState = true
                }
                
            }
            
        }
        //会调用draw 方法
        setNeedsDisplay()
    }
    
    
    //松手的时候调用
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.fingurePoint = CGPoint.zero
        
        if (self.selectPointArray.count < minUnlockCount) {
            self.resetNoSelectUI()
            delegate?.didFailUnlockGesture(error: .lessUnlockNum)
        } else {
            delegate?.didEndUnlockGesture(passwordTag: selectPointArray)
        }
        
        setNeedsDisplay()
        
    }
    
}

//MARK: - 代理事件
protocol CSIGestureUnlockViewDelegate {
    /// 手势操作完毕（我的想法是：加密存储这个数组）
    /// 设置手势的时候根据第一次第二次响应这个代理，比较两次的数组
    func didEndUnlockGesture(passwordTag: [UnlockPointTag])
    /// 手势操作失败
    func didFailUnlockGesture(error: CSIUnlockErrorType)
}
