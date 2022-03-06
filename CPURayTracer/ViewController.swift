//
//  ViewController.swift
//  CPURayTracer
//
//  Created by chris on 2/20/22.
//

import Cocoa

class ViewController: NSViewController {

    var canvas: CanvasView!
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.view = NSView(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvas = CanvasView(frame: self.view.bounds)
        self.view.addSubview(canvas)
        
        canvas.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        runRayTracer()
    }
    
    func runRayTracer() {
        let rayTracer = RayTracer(scene: Scene.Samples.fourSpheres, bounds: canvas.bounds)
        rayTracer.run(canvas: canvas)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

