//
//  ViewController.swift
//  SocketCanvas
//
//  Created by Robert Paul on 10/12/16.
//  Copyright © 2016 Robert Paul. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController, SocketManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: Color settings
    var brushColor: CIColor = CIColor.magenta()
    var brushWidth: CGFloat = 10.0
    var alpha: CGFloat = 1.0
    var count = 0;
    
    // MARK: Drawing vars
    var lastPoint = CGPoint.zero
    var swiped = false
    
    // MARK: Outlets
    @IBOutlet var colorPicker: UIButton!
    @IBOutlet weak var tempImageView: UIImageView!
    
    // MARK: SocketManagerDelegate

    internal func clearCanvas() {
        print("Trying to clear")
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            
            context.clear(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempImageView.alpha = alpha
        } else {
            print("Error: Drawing context not found!!!")
        }
        UIGraphicsEndImageContext()
    }
    
    internal func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, with color: CGColor) {
        print("Draw from: \(fromPoint), toPoint: \(toPoint), with color: \(color)")
        
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            
            context.move(to: fromPoint)
            context.addLine(to: toPoint)
            
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(brushWidth)
            
            context.setLineJoin(.round)
            
            context.setStrokeColor(color)
            
            context.strokePath()
            
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempImageView.alpha = alpha
        } else {
            print("Error: Drawing context not found!!!")
        }
        UIGraphicsEndImageContext()
        
    }
    
    // MARK: Drawing functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            SocketManager.getInstance().drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint, with: brushColor)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            SocketManager.getInstance().drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint, with: brushColor)
        }
    }
    
    // MARK: Color picker button
    
    @IBAction func colorPickerPressed(_ sender: UIButton) {

        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 284, height: 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
    }

    @IBAction func erase(_ sender: UIButton) {
        clearScreenRequest()
    }
    
    func clearScreenRequest(){
        //implement function to send erase request to server
        SocketManager.getInstance().clearScreenRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketManager.getInstance().delegate = self
        colorPicker.backgroundColor = UIColor(ciColor: CIColor.magenta())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Override the iPhone behavior that presents a popover as fullscreen
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    func setButtonColor (_ color: UIColor) {
        colorPicker.setTitleColor(color, for:UIControlState())
    }
    
    // MARK: Clear switch
    
    @IBAction func clearToggle(_ sender: UISwitch) {
        if (sender.isOn) {
            SocketManager.getInstance().clearCanvasReady()
        } else {
            SocketManager.getInstance().clearCanvasUnready()
        }
    }
}

