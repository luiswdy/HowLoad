//
//  DecibelMeter.swift
//  HowLoud
//
//  Created by Luis Wu on 4/29/16.
//  Copyright © 2016 Luis Wu. All rights reserved.
//

import Foundation
import AVFoundation

// Arguments go here
private struct Args {
    static let referenceLevel: Float = 5
    static let maxValue: Float = 160
    static let offset: Float = 50
    static let defaultSamplingInteval: NSTimeInterval = 0.1  // in sec
    static let defaultSamplingRate: Float = 44100
    static let numOfChannels: UInt = 1
    static let nullURL = NSURL(fileURLWithPath: "/dev/null")    // we are not going to record sound to a file, so redirect the recording output to null device
    static let recordSettings = [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatAppleLossless),
                                 AVSampleRateKey: NSNumber(int: 44100),
                                 AVNumberOfChannelsKey: NSNumber(int: 1)]
}

class DecibelMeter {
    static let MaxValue = Int(Args.maxValue)
    static let MinValue = 0
    
    private var levelTimer: NSTimer! = nil
    private let recorder: AVAudioRecorder
    private let dBHandler: (Float, Float) -> Void
    private let samplingInterval: NSTimeInterval
    
    lazy var isMicGranted: Bool = {
        return AVAudioSession.sharedInstance().recordPermission() == .Granted
    }()
    
    init(dBHandler: (Float, Float) -> Void, samplingRate: Float = Args.defaultSamplingRate, samplingInterval: NSTimeInterval = Args.defaultSamplingInteval) {
        // check microphone authorization
        self.samplingInterval = samplingInterval
        self.dBHandler = dBHandler
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { (granted) in
            if granted {
                print("Granted")
            } else {
                print("Not granted")
            }
        }
        
        // setup audio session
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        try! AVAudioSession.sharedInstance().setMode(AVAudioSessionModeMeasurement)  // disable Automatic Gain Control (AGC)
        //        assert(AVAudioSession.sharedInstance().inputGain == 1.0)
        
        // setup audio recorder
        self.recorder = try! AVAudioRecorder(URL: Args.nullURL, settings: Args.recordSettings)
        print("Is the recorder prepared to record? \(recorder.prepareToRecord())")
        self.recorder.meteringEnabled = true    // enable audio level metering
    }
    
    @objc func handleDecibels(sender: NSTimer) {    // added @objc annotation as selector of NSTimer take only objc method as an argument
        self.recorder.updateMeters()
        let avgSpl: Float = 20 * log10(Args.referenceLevel * powf(10.0, (self.recorder.averagePowerForChannel(0) / 20)) * Args.maxValue) + Args.offset
        let peakSpl: Float = 20 * log10(Args.referenceLevel * powf(10.0, (self.recorder.peakPowerForChannel(0) / 20)) * Args.maxValue) + Args.offset
        print("avgSpl: \(avgSpl), peakSpl: \(peakSpl)")
        self.dBHandler(avgSpl, peakSpl)
    }
    
    func startMeasuring() {
        if self.levelTimer == nil {
            self.levelTimer = NSTimer.scheduledTimerWithTimeInterval(self.samplingInterval,
                                                                     target: self,
                                                                     selector: #selector(handleDecibels(_:)),
                                                                     userInfo: nil,
                                                                     repeats: true)
        }
        
        if !self.recorder.recording {
            do {
                self.recorder.record()
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print("audio session setActive failed - error: \(error)")
            }
        }
    }
    
    func stopMeasuring() {
        if self.recorder.recording {
            do {
                self.recorder.stop()
                try AVAudioSession.sharedInstance().setActive(false)
            } catch let error as NSError {
                print("audio session setActive failed - error: \(error)")
            }
        }
        self.levelTimer?.invalidate()
        self.levelTimer = nil
    }
    
    func isMeasuring() -> Bool {
        return self.recorder.recording
    }
}