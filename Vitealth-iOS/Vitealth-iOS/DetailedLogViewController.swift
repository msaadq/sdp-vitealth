//
//  DetailedLogViewController.swift
//  Vitealth-iOS
//
//  Created by Saad Qureshi on 2/26/17.
//  Copyright © 2017 Saad Qureshi. All rights reserved.
//

import UIKit
import Charts

class DetailedLogViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var lineBarGraph: LineChartView!
    
    @IBOutlet weak var daySelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        switch daySelector.selectedSegmentIndex {
        case 0:
            setChart(doseData: DashboardViewController.todayDailyDosesBolus)
            
        case 1:
            setChart(doseData: DashboardViewController.yestDailyDosesBolus)
            
        default:
            break
            
        }
        
    }
    
    func setChart(doseData: [Dose]) {
        var bglEntries: [ChartDataEntry] = []
        var insulinEntries: [ChartDataEntry] = []
        
        var dataTempEntry: ChartDataEntry!
        
        for dose in doseData {
            dataTempEntry = ChartDataEntry(x: Double(dose.timeofday), y: Double(dose.glucose))
            bglEntries.append(dataTempEntry)
            
            dataTempEntry = ChartDataEntry(x: Double(dose.timeofday), y: Double(dose.insulinQuant))
            insulinEntries.append(dataTempEntry)
            
        }
        
        var dataSetsLine = [IChartDataSet]()
        
        let foodQualityTasteRatingSet = LineChartDataSet(values: bglEntries, label: "Blood Glucose (mg/dl)")
        dataSetsLine.append(foodQualityTasteRatingSet)
        foodQualityTasteRatingSet.circleRadius = 2.5
        foodQualityTasteRatingSet.setCircleColor(.red)
        foodQualityTasteRatingSet.setColor(UIColor.red.withAlphaComponent(0.8))
        foodQualityTasteRatingSet.axisDependency = .left
        foodQualityTasteRatingSet.mode = .horizontalBezier
        
        
        let hygieneRatingSet = LineChartDataSet(values: insulinEntries, label: "Insulin (units)")
        dataSetsLine.append(hygieneRatingSet)
        hygieneRatingSet.circleRadius = 2.5
        hygieneRatingSet.mode = .horizontalBezier
        hygieneRatingSet.setCircleColor(.blue)
        hygieneRatingSet.setColor(UIColor.blue.withAlphaComponent(0.8))

        hygieneRatingSet.axisDependency = Charts.YAxis.AxisDependency.right
        foodQualityTasteRatingSet.axisDependency = Charts.YAxis.AxisDependency.left
        
        let lineChartData = LineChartData(dataSets: dataSetsLine)
        lineChartData.setDrawValues(false)
        self.lineBarGraph.data = lineChartData
        self.lineBarGraph.descriptionTextColor = UIColor.white
        self.lineBarGraph.gridBackgroundColor = UIColor.darkGray
        self.lineBarGraph.animate(xAxisDuration: 0, yAxisDuration: 0.3, easingOption: .easeInSine)
        //self.lineBarGraph.rightAxis.enabled = false
        self.lineBarGraph.xAxis.drawGridLinesEnabled = true
        self.lineBarGraph.leftAxis.labelTextColor = .red
        self.lineBarGraph.rightAxis.labelTextColor = .blue
        
        
//        self.lineChart.xAxis.axisMinimum = 0
//        self.lineChart.xAxis.axisMaximum = Double(fqtData.count - 1)
//        self.lineChart.leftAxis.axisMaximum = 3
//        self.lineChart.leftAxis.axisMinimum = 0
//        self.lineChart.xAxis.drawLabelsEnabled = false
//        self.lineChart.rightAxis.enabled = false
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
