//
//  GraphViewController.swift
//  Calculator
//

import UIKit

class GraphViewController: UIViewController {
    
     var yForX: (( x: Double) -> Double?)?  { didSet { updateUI() } }
    
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.scale(_:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.originMove(_:))))
            
            let doubleTapRecognizer = UITapGestureRecognizer(
                target: graphView, action: #selector(GraphView.origin(_:)))
            
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            
            graphView.scale = scale
            graphView.originRelativeToCenter = originRelativeToCenter
        updateUI()
        }
    }
    
    func updateUI() {
        graphView?.yForX = yForX
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    private struct Keys {
        static let Scale = "GraphViewController.Scale"
        static let Origin = "GraphViewController.Origin"
    }
    
    var scale: CGFloat {
        get { return defaults.objectForKey(Keys.Scale) as? CGFloat ?? 50.0 }
        set { defaults.setObject(newValue, forKey: Keys.Scale) }
    }
    
    var originRelativeToCenter: CGPoint {
        get {
            let originArray = defaults.objectForKey(Keys.Origin) as? [CGFloat]
            
            let factor = CGPoint(x: originArray?.first ?? CGFloat (0.0),
                           y: originArray?.last ?? CGFloat (0.0))
            
            return CGPoint (x: factor.x * graphView.bounds.size.width,
                            y: factor.y * graphView.bounds.size.height)

        }
        set {
            let factor =
                CGPoint(x: newValue.x / graphView.bounds.size.width,
                        y: newValue.y / graphView.bounds.size.height)
            
            defaults.setObject([factor.x, factor.y], forKey: Keys.Origin)
        }
    }

    var widthOld = CGFloat(0.0)
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        widthOld = graphView.bounds.size.width
        originRelativeToCenter = graphView.originRelativeToCenter
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !(graphView.bounds.size.width == widthOld) {
           graphView.originRelativeToCenter =  originRelativeToCenter
        }
    }
   
       override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        scale = graphView.scale
        originRelativeToCenter = graphView.originRelativeToCenter
    }
}