//
//  ViewController.swift
//  AR Measure
//
//  Created by udaykanthd on 21/06/18.
//  Copyright © 2018 udaykanthd. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var StatusLabel: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    var measurementTextNode = SCNNode()
    var currentSessionStatus = ARSessionStateStatus.initialized {
        didSet {
            DispatchQueue.main.async { self.StatusLabel.text = self.currentSessionStatus.statusDescription }
            if currentSessionStatus == .failed {
                //clear ARSession()
            }
        }
    }
    var dotNodes = [SCNNode]() {
        didSet {
            if dotNodes.count > 0 {
                currentSessionStatus = .ready
            } else {
                if currentSessionStatus == .ready {
                    currentSessionStatus = .initialized
                    
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        StatusLabel.layer.cornerRadius = 20.0
        StatusLabel.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
         if dotNodes.count > 0 { self.currentSessionStatus = .ready }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        self.currentSessionStatus = .temporarilyUnAvailable
    }
    // MARK: - Touch Delegates
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if currentSessionStatus != .ready {
//            print("Unable to place objects when the planes are not ready...")
//            return
//        }
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchedLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchedLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addNewDot(at: hitResult)
            }
            
        }
    }
    func addNewDot(at hitResult:ARHitTestResult) {
        let redDotGeometry = SCNSphere(radius: 0.003)
        let redDotMaterial = SCNMaterial()
        redDotMaterial.diffuse.contents = UIColor.red
        redDotGeometry.materials = [redDotMaterial]
        let redDotNode = SCNNode(geometry: redDotGeometry)
        redDotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(redDotNode)
        dotNodes.append(redDotNode)
        if dotNodes.count >= 2 {
            measureDistance()
        }
        
    }
    func measureDistance()  {
        let firstNode = dotNodes[0]
        let lastNode = dotNodes[1]
        let distance = sqrt(pow(lastNode.position.x - firstNode.position.x, 2) + pow(lastNode.position.y - firstNode.position.y, 2) + pow(lastNode.position.z - firstNode.position.z, 2))
        updateText(text: "\(abs(distance))", atPosition:lastNode.position)
    }
    func updateText(text lableText: String, atPosition position:SCNVector3)  {
        measurementTextNode.removeFromParentNode()
        let textGeometry = SCNText(string: lableText, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        measurementTextNode = SCNNode(geometry: textGeometry)
        measurementTextNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        measurementTextNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(measurementTextNode)
    }
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
         self.currentSessionStatus = .failed
    }
    func sessionWasInterrupted(_ session: ARSession) {
         self.currentSessionStatus = .temporarilyUnAvailable
    }
    func sessionInterruptionEnded(_ session: ARSession) {
         self.currentSessionStatus = .ready
    }
    
    
}
