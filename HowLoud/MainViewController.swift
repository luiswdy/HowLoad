//
//  ViewController.swift
//  HowLoud
//
//  Created by Luis Wu on 4/29/16.
//  Copyright © 2016 Luis Wu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private var presenter = MainPresenter()
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var avgSplLabel: UILabel!
    @IBOutlet weak var peakSplLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var gauge: Gauge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.gauge.maxValue = CGFloat(DecibelMeter.MaxValue)
        self.gauge.minValue = CGFloat(DecibelMeter.MinValue)
        self.minValueLabel.text = presenter.decibelMeterMinValue
        self.maxValueLabel.text = presenter.decibelMeterMaxValue
        self.presenter.subscribeDecibelInfo { [unowned self] (avgSpl, avgInfo, peakInfo) in
            self.gauge.value = avgSpl
            self.avgSplLabel.text = avgInfo
            self.peakSplLabel.text = peakInfo
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMeasuring(sender: UIButton) {
        sender.selected = presenter.toggleMeasuring()
    }
}

