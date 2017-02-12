//
//  ViewController.swift
//  mu
//
//  Created by Stiven Deleur on 2/11/17.
//  Copyright © 2017 Stiven Deleur. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener {

    var muse : IXNMuse?;
    var manager : IXNMuseManagerIos?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func receive(_: IXNMuseConnectionPacket, muse:IXNMuse?){
        
    }
    
    func receive(_: IXNMuseDataPacket?, muse: IXNMuse?){
        
    }
    
    func receive(_: IXNMuseArtifactPacket, muse: IXNMuse?){
        
    }
    
    func museListChanged(){
        
    }
    
    func receiveLog(_:IXNLogPacket){
        
    }
}

