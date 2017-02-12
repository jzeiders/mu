//
//  ViewController.swift
//  mu
//
//  Created by Stiven Deleur on 2/11/17.
//  Copyright © 2017 Stiven Deleur. All rights reserved.
//

import UIKit
import Starscream
import HealthKit
import WatchConnectivity
import Charts

class ViewController: UIViewController, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener, WCSessionDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var muse : IXNMuse?;
    var manager : IXNMuseManager?
    var socket = WebSocket(url: URL(string: "ws://281b343a.ngrok.io/muse_socket")!)
    let classifications = ["Relaxed", "Focused", "Hyped"]
    @IBOutlet weak var heartRateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var websocketButton: UIButton!
    @IBOutlet weak var eegLineChart: LineChartView!
    
    let graphWidth = 100
    let lineWidth : CGFloat = 2.0
    
    var deltaData = [ChartDataEntry]()
    var thetaData = [ChartDataEntry]()
    var alphaData = [ChartDataEntry]()
    var betaData = [ChartDataEntry]()
    var gammaData = [ChartDataEntry]()
    
    var deltaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "delta")
    var thetaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "theta")
    var alphaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "alpha")
    var betaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "beta")
    var gammaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "gamma")
    
    let data = LineChartData(dataSets: [LineChartDataSet]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.connect()
        manager = IXNMuseManagerIos.sharedManager()
        manager?.setMuseListener(self)
        IXNLogManager.instance()?.setLogListener(self)
        manager?.startListening()
        statusLabel.text = "Status: Searching for Muse..."
        
        if WCSession.isSupported() { //makes sure it's not an iPad or iPod
            let watchSession = WCSession.default()
            watchSession.delegate = self
            watchSession.activate()
        }
        websocketButton.layer.cornerRadius = 20
        
        eegLineChart.noDataText = "Connect the Muse to display data"
        
        deltaDataSet.lineWidth = lineWidth
        thetaDataSet.lineWidth = lineWidth
        alphaDataSet.lineWidth = lineWidth
        betaDataSet.lineWidth = lineWidth
        gammaDataSet.lineWidth = lineWidth
        
        deltaDataSet.circleRadius = 0
        thetaDataSet.circleRadius = 0
        alphaDataSet.circleRadius = 0
        betaDataSet.circleRadius = 0
        gammaDataSet.circleRadius = 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func receive(_ packet: IXNMuseConnectionPacket, muse:IXNMuse?){
        manager?.stopListening()
        if packet.currentConnectionState == IXNConnectionState.disconnected {
            manager?.startListening()
            statusLabel.text = "Status: Searching for Muse..."
        }else if packet.currentConnectionState == IXNConnectionState.connecting {
            statusLabel.text = "Status: Connecting to \(muse!.getMacAddress())"
        }else if packet.currentConnectionState == IXNConnectionState.connected {
            statusLabel.text = "Status: Connected to \(muse!.getMacAddress())"
        }else if packet.currentConnectionState == IXNConnectionState.unknown {
            statusLabel.text = "Status: Unknown"
        }
    }
    
    func writeToSocket( param: String, data: Array<Float>){
        var jsonObject = [String: Array<Float>]()
        
        var sanitizedData = [Float]()
        
        for num in data{
            if num.isNaN{
                sanitizedData.append(-1)
            }else{
                sanitizedData.append(num)
            }
        }
        jsonObject[param] = sanitizedData
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
//            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
//            print(jsonString)
            socket.write(data: jsonData)
            
        } catch {
            print ("JSON Failure")
        }
        
    }
    
    func updateGraph(){
        
        deltaDataSet.values = deltaData
        thetaDataSet.values = thetaData
        alphaDataSet.values = alphaData
        betaDataSet.values = betaData
        gammaDataSet.values = gammaData
        
        data.dataSets = [deltaDataSet, thetaDataSet, alphaDataSet, betaDataSet, gammaDataSet]
        
        eegLineChart.data = data
    }
    
    func getAvg(_ arr: Array<Float>) ->Double{
        var sum:Float = 0
        var cnt = 0
        for num in arr{
            if !num.isNaN{
                sum += num
                cnt += 1
            }
        }
        if cnt == 0{
            return 0
        }else{
            return Double(sum/Float(cnt))
        }
    }
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?){
//        print("Recieved \(packet!.packetType()): \(packet!.values())")
        
        let val = packet!.values() as Array<Float>
        var avg = getAvg(val)
        if avg.isNaN{
            avg = 0
        }
        if packet!.packetType() == IXNMuseDataPacketType.deltaRelative {
            writeToSocket(param: "delta_relative", data: val)
            
            deltaData.append(ChartDataEntry(x: Double(deltaData.count), y: avg))
        }else if packet!.packetType() == IXNMuseDataPacketType.thetaRelative {
            writeToSocket(param: "theta_relative", data: val)
            
            thetaData.append(ChartDataEntry(x: Double(thetaData.count), y: avg))
        }else if packet!.packetType() == IXNMuseDataPacketType.alphaRelative {
            writeToSocket(param: "alpha_relative", data: val)
            
            alphaData.append(ChartDataEntry(x: Double(alphaData.count), y: avg))
        }else if packet!.packetType() == IXNMuseDataPacketType.betaRelative {
            writeToSocket(param: "beta_relative", data: val)
            
            betaData.append(ChartDataEntry(x: Double(betaData.count), y: avg))
        }else if packet!.packetType() == IXNMuseDataPacketType.gammaRelative {
            writeToSocket(param: "gamma_relative", data: val)
            
            gammaData.append(ChartDataEntry(x: Double(gammaData.count), y: avg))
        }
        updateGraph()
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?){
        if (packet.blink) {
            print("blink detected")
        }
        if (packet.headbandOn) {
            print("headband on")
        }
        if (packet.jawClench) {
            print("jaw clench detected")
        }
    }
    
    
    func museListChanged(){
        print("MUSE LIST CHANGED")
        if (manager?.getMuses().count == 0){
            manager?.startListening()
            statusLabel.text = "Status: Searching for Muse..."
            return
        }
        manager?.stopListening()
        muse = manager?.getMuses()[0]
        
        muse?.register(self)
        muse?.register(self, type: IXNMuseDataPacketType.deltaRelative)
        muse?.register(self, type: IXNMuseDataPacketType.thetaRelative)
        muse?.register(self, type: IXNMuseDataPacketType.alphaRelative)
        muse?.register(self, type: IXNMuseDataPacketType.betaRelative)
        muse?.register(self, type: IXNMuseDataPacketType.gammaRelative)
        
        muse?.runAsynchronously()
    }
    
    func receiveLog(_ packet:IXNLogPacket){
        print("\(packet.tag): \(packet.timestamp) raw:\(packet.raw) \(packet.message)")
    }
    
    
    @IBAction func reopenSocket(_ sender: UIButton) {
        if (socket.isConnected){
            socket.disconnect(forceTimeout: 0, closeCode: 0)
            sender.backgroundColor = UIColor.red
        }else{
            socket.connect()
            sender.backgroundColor = UIColor.green
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession){
        
    }
    
    
    func sessionDidDeactivate(_ session: WCSession){
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        if applicationContext["heart_rate"] != nil{
            writeToSocket(param: "heart_rate", data: [applicationContext["heart_rate"] as! Float])
            DispatchQueue.main.async(){
                self.heartRateLabel.text = String(applicationContext["heart_rate"] as! Int)
            }
        }
    }
    @IBAction func getHeartRate(_ sender: UIButton) {
        if WCSession.isSupported() { //makes sure it's not an iPad or iPod
            let watchSession = WCSession.default()
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    @IBAction func connectToMuse(_ sender: UIButton) {
        manager?.startListening()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return classifications.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return classifications[row]
    }
}

