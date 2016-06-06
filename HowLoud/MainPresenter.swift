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
            return String(format: NSLocalizedString("gauge_range_format_string", comment: "format string"), _decibelMeterMinValue)
        }
    }
    var decibelMeterMaxValue: String? {
        get {
            return String(format: NSLocalizedString("gauge_range_format_string", comment: "format string"), _decibelMeterMaxValue)
        }
    }
    
    lazy var decibelMeter: DecibelMeter = DecibelMeter(dBHandler: { [weak self] (avgSpl, peakSpl) in
        let avgInfo = String(format: NSLocalizedString("avg_format_string",comment: "format string"), avgSpl)
        let peakInfo = String(format: NSLocalizedString("peak_format_string",comment: "format string"), peakSpl)
        self?.decibelInfoClosure?(CGFloat(avgSpl), avgInfo, peakInfo)
        })
    
    func subscribeDecibelInfo(closure: (CGFloat, String, String) -> Void) {
        decibelInfoClosure = closure
    }
    
    func allowMic() -> Bool {
        return decibelMeter.isMicGranted
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
