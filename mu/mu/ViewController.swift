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

class ViewController: UIViewController, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener, WCSessionDelegate, UIPickerViewDataSource, UIPickerViewDelegate, WebSocketDelegate {

    var muse : IXNMuse?;
    var manager : IXNMuseManager?
    var socket = WebSocket(url: URL(string: "ws://mu-websocket-server.herokuapp.com/muse_socket")!)
    var parsedDataSocket = WebSocket(url: URL(string: "ws://mu-websocket-server.herokuapp.com/parsed_data")!)
    
    let classifications = ["Relaxed", "Focused", "Hyped"]
    @IBOutlet weak var heartRateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var websocketButton: UIButton!
    @IBOutlet weak var eegLineChart: LineChartView!
    @IBOutlet weak var moodPicker: UIPickerView!
    @IBOutlet weak var playbackView: UIView!
    
    @IBOutlet weak var detectedMoodLabel: UILabel!
    @IBOutlet weak var songPlayingLabel: UILabel!
    @IBOutlet weak var songScoreLabel: UILabel!
    var heartRate: Float = -1
    
    let graphWidth = 100
    let lineWidth : CGFloat = 3.0
    
    var deltaData = [Double]()
    var thetaData = [Double]()
    var alphaData = [Double]()
    var betaData = [Double]()
    var gammaData = [Double]()
    
    var deltaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "Delta")
    var thetaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "Theta")
    var alphaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "Alpha")
    var betaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "Beta")
    var gammaDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "Gamma")
    
    let data = LineChartData(dataSets: [LineChartDataSet]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parsedDataSocket.delegate = self
        
        socket.connect()
        parsedDataSocket.connect()
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
        playbackView.isHidden = true
        
        
        
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
        
        deltaDataSet.setColor(ChartColorTemplates.joyful()[0])
        thetaDataSet.setColor(ChartColorTemplates.joyful()[1])
        alphaDataSet.setColor(ChartColorTemplates.joyful()[2])
        betaDataSet.setColor(ChartColorTemplates.joyful()[3])
        gammaDataSet.setColor(ChartColorTemplates.joyful()[4])
        
        eegLineChart.backgroundColor = UIColor.clear
        eegLineChart.noDataTextColor = UIColor.white
        eegLineChart.drawBordersEnabled = false
        eegLineChart.drawGridBackgroundEnabled = false
        eegLineChart.xAxis.drawLabelsEnabled = false
        eegLineChart.noDataText = "Connect the Muse to display data"
        eegLineChart.chartDescription?.text = ""
        eegLineChart.xAxis.drawGridLinesEnabled = false
        eegLineChart.leftAxis.drawGridLinesEnabled = false
        eegLineChart.rightAxis.drawGridLinesEnabled = false
        eegLineChart.xAxis.drawAxisLineEnabled = false
        eegLineChart.rightAxis.drawAxisLineEnabled = false
        eegLineChart.rightAxis.drawLabelsEnabled = false
        eegLineChart.leftAxis.drawAxisLineEnabled = false
        eegLineChart.leftAxis.drawLabelsEnabled = false
        eegLineChart.xAxis.axisMaximum = 100
//        eegLineChart.leftAxis.axisMaximum = 1
        eegLineChart.xAxis.axisMinimum = 0
        eegLineChart.leftAxis.axisMinimum = 0
        eegLineChart.legend.textColor = UIColor.white
        
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
        
        var deltaChartData = [ChartDataEntry]()
        var thetaChartData = [ChartDataEntry]()
        var alphaChartData = [ChartDataEntry]()
        var betaChartData = [ChartDataEntry]()
        var gammaChartData = [ChartDataEntry]()
        
        var i = 0
        while i < graphWidth {
            if deltaData.count > i{
                deltaChartData.append(ChartDataEntry(x: Double(i), y: deltaData[i]))
            }
            if thetaData.count > i{
            thetaChartData.append(ChartDataEntry(x: Double(i), y: thetaData[i]))
                }
            if alphaData.count > i{
                alphaChartData.append(ChartDataEntry(x: Double(i), y: alphaData[i]))
            }
            if betaData.count > i{
                betaChartData.append(ChartDataEntry(x: Double(i), y: betaData[i]))
            }
            if gammaData.count > i{
                gammaChartData.append(ChartDataEntry(x: Double(i), y: gammaData[i]))
            }
            i += 1
        }
        
        deltaDataSet.values = deltaChartData
        thetaDataSet.values = thetaChartData
        alphaDataSet.values = alphaChartData
        betaDataSet.values = betaChartData
        gammaDataSet.values = gammaChartData
        
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
            
            if deltaData.count == graphWidth{
                deltaData.remove(at: 0)
            }
            deltaData.append(avg)
        }else if packet!.packetType() == IXNMuseDataPacketType.thetaRelative {
            writeToSocket(param: "theta_relative", data: val)
            
            if thetaData.count == graphWidth{
                thetaData.remove(at: 0)
            }
            thetaData.append(avg)
        }else if packet!.packetType() == IXNMuseDataPacketType.alphaRelative {
            writeToSocket(param: "alpha_relative", data: val)
            
            if alphaData.count == graphWidth{
                alphaData.remove(at: 0)
            }
            alphaData.append(avg)
        }else if packet!.packetType() == IXNMuseDataPacketType.betaRelative {
            writeToSocket(param: "beta_relative", data: val)
            
            if betaData.count == graphWidth{
                betaData.remove(at: 0)
            }
            betaData.append(avg)
        }else if packet!.packetType() == IXNMuseDataPacketType.gammaRelative {
            writeToSocket(param: "gamma_relative", data: val)
            
            if gammaData.count == graphWidth{
                gammaData.remove(at: 0)
            }
            gammaData.append(avg)
            
            if avg != 0 {
                writeToSocket(param: "heart_rate", data: [heartRate])
            }
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
        if (!socket.isConnected || !parsedDataSocket.isConnected){
            socket.connect()
            parsedDataSocket.connect()
            sender.backgroundColor = UIColor.green
        }else{
            socket.disconnect(forceTimeout: 0, closeCode: 0)
            parsedDataSocket.disconnect(forceTimeout: 0, closeCode: 0)
            sender.backgroundColor = UIColor.red
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
            heartRate = applicationContext["heart_rate"] as! Float
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = NSAttributedString(string: classifications[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        return str
    }
    
    @IBAction func segmentedControlSwitched(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            moodPicker.isHidden = false
            playbackView.isHidden = true
        }else{
            moodPicker.isHidden = true
            playbackView.isHidden = false
        }
    }
    
    
    func websocketDidConnect(socket: WebSocket){
        
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?){
        
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String){
        print("WEBSOCKET: \(text)")
        if (text == "hi"){
            return
        }
    
        
        let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            if let classification = json["classification"] as? Int {
                detectedMoodLabel.text = "Detected Mood: \(classifications[classification])"
            }
            if let song_id = json["song-id"] as? String {
                songPlayingLabel.text = "Playing Song: #\(song_id)"
            }
            if let song_rating = json["song-rating"] as? Double {
                var song_rating_perc = lround(song_rating*150)
                if song_rating_perc > 100{
                    song_rating_perc = 100
                }
                songScoreLabel.text = "\(song_rating_perc)%"
            }
        } catch let error as NSError {
            print("Failed to load JSON: \(error.localizedDescription)")
        }
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data){
        
    }
    
}

