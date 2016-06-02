//
//  MainPresenter.swift
//  HowLoud
//
//  Created by Luis Wu on 6/2/16.
//  Copyright © 2016 Luis Wu. All rights reserved.
//

import UIKit

class MainPresenter {
    private var _decibelMeterMinValue = DecibelMeter.MinValue
    private var _decibelMeterMaxValue = DecibelMeter.MaxValue
    private var decibelInfoClosure: ((CGFloat, String, String) -> Void)? = nil
    
    var decibelMeterMinValue: String? {
        get {
            return String(format: "%d dB", _decibelMeterMinValue)
        }
    }
    var decibelMeterMaxValue: String? {
        get {
            return String(format: "%d dB", _decibelMeterMaxValue)
        }
    }
    
    lazy var decibelMeter: DecibelMeter = DecibelMeter(dBHandler: { [weak self] (avgSpl, peakSpl) in
        let avgInfo = String(format: "AVG: %.2f dB", avgSpl)
        let peakInfo = String(format: "Peak: %.2f dB", peakSpl)
        self?.decibelInfoClosure?(CGFloat(avgSpl), avgInfo, peakInfo)
        })
    
    func subscribeDecibelInfo(closure: (CGFloat, String, String) -> Void) {
        decibelInfoClosure = closure
    }
    
    func toggleMeasuring() -> Bool {
        if decibelMeter.isMeasuring() {
            decibelMeter.stopMeasuring()
        } else {
            decibelMeter.startMeasuring()
        }
        return decibelMeter.isMeasuring()
    }
    
}
