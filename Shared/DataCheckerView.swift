//
//  DataCheckerView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/1/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct DataCheckerView: View {
    @ObservedObject var dataChecker: DataChecker

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: {
                    dataChecker.check()
                }) {
                    Text("Check data").font(.body)
                }
            }.padding()
            List {
                ForEach(dataChecker.reports, id: \.name) {
                    DataCheckReportView(report: $0)
                }
            }
        }
    }
}

struct DataCheckerView_Previews: PreviewProvider {
    static var previews: some View {
        DataCheckerView(dataChecker: DataChecker(document: mockDocument))
    }
}
