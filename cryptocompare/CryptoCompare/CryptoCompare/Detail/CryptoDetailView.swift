//
//  CryptoDetailView.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI
import Charts
import GridPoint

struct CryptoDetailView: View {
    
    @ObservedObject var viewAdapter: CryptoDetailViewAdapter
    
    var body: some View {
        ZStack {
            if !viewAdapter.detailModels.isEmpty {
                VStack(spacing: GridPoint.x4) {
                    chartView()
                    if !viewAdapter.detailModels.isEmpty {
                        detailsListView
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, GridPoint.x2)
                    }
                    
                    Spacer()
                }
                .padding(.top, GridPoint.x4)
                .task {
                    viewAdapter.startTimer()
                }
            }
            
            if viewAdapter.detailModels.isEmpty {
                loadingView
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("crypto_details".localized())
    }
    
    private var detailsListView: some View {
        VStack(spacing: 8) {
            ForEach(viewAdapter.detailModels) { value in
                VStack(spacing: 8) {
                    HStack {
                        Text(value.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(value.value) \(value.currency)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Divider()
                }
                .padding(.horizontal, GridPoint.x2)
            }
        }
        .padding(.vertical, GridPoint.x2)
    }
    
    private func chartView() -> some View {
        ChartView(pricePoints: $viewAdapter.pricePoints)
            .frame(height: 250)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .padding(.horizontal, GridPoint.x2)
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("loading".localized())
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct ChartView: View {
    
    @Binding var pricePoints: [CryptoPricePoint]
    private var daysRange: ClosedRange<Date>
    
    init(pricePoints: Binding<[CryptoPricePoint]>) {
        self._pricePoints = pricePoints
        let currentDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        self.daysRange = startDate...currentDate
    }
    
    var body: some View {
        Chart {
            ForEach(pricePoints) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Price", point.price)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day().month(), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartXScale(domain: daysRange)
    }
}

struct BuyCryptoGuideView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("buy_cryptocurrencies_title".localized())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Text("buy_cryptocurrencies_intro".localized())
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    Divider()
                    
                    stepView(stepNumber: 1, title: "step_1_title".localized(), description: "step_1_description".localized(), imageName: "building.2.fill")
                    
                    stepView(stepNumber: 2, title: "step_2_title".localized(), description: "step_2_description".localized(), imageName: "person.crop.circle.fill")
                    
                    stepView(stepNumber: 3, title: "step_3_title".localized(), description: "step_3_description".localized(), imageName: "creditcard.fill")
                    
                    stepView(stepNumber: 4, title: "step_4_title".localized(), description: "step_4_description".localized(), imageName: "bitcoinsign.circle.fill")
                    
                    stepView(stepNumber: 5, title: "step_5_title".localized(), description: "step_5_description".localized(), imageName: "checkmark.circle.fill")
                    
                    stepView(stepNumber: 6, title: "step_6_title".localized(), description: "step_6_description".localized(), imageName: "lock.fill")
                    
                    Divider()
                    
                    Text("tips_and_advice_title".localized())
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    Text("tips_and_advice_body".localized())
                        .font(.body)
                        .padding(.bottom, 20)
                    
                }
                .padding()
            }
            .navigationTitle("navigation_title".localized())
        }
    }
    
    private func stepView(stepNumber: Int, title: String, description: String, imageName: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\("step".localized()) \(stepNumber):")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            Text(title)
                .font(.headline)
                .padding(.bottom, 2)
            Text(description)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct BuyCryptoGuideView_Previews: PreviewProvider {
    static var previews: some View {
        BuyCryptoGuideView()
    }
}
