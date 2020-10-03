//
//  ServiceEditView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/29/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct ServicesEditView: View {
    @Binding var member: Member
    
    var body: some View {
        ForEach(0..<member.services.count, id: \.self) {
            ServiceEditRowView(member: self.$member, index: $0)
        }
    }
}

struct ServicesEditAddView: View {
    @Binding var member: Member
    
    var body: some View {
        Button(action: {
            appendEmptyService(to: self.$member)
        }) {
            Image(systemName: "plus").font(.body)
        }
    }
}

fileprivate func appendEmptyService(to member: Binding<Member>) {
    member.services.wrappedValue.append(PMDataTypes.Service())
}

struct ServiceEditRowView: View {
    @Binding var member: Member
    var index: Int

    var body: some View {
        NavigationLink(destination: ServiceEditView(member: $member, index: index)) {
            Text("\(dateForDisplay(member.services[index].date))  \(member.services[index].type.rawValue)")
                .font(.body)
        }
    }
}

struct ServiceEditView: View {
    @Binding var member: Member
    var index: Int

    var body: some View {
        Form {
            Section {
                EditOptionalDateView(caption: "date:", date: $member.services[index].date)
                EditDateButton(caption: "date:", date: $member.services[index].date)
                EditServiceTypeView(caption: "type:", serviceType: $member.services[index].type)
                EditOptionalTextView(caption: "place:", text: $member.services[index].place)
                EditOptionalTextView(caption: "comment:", text: $member.services[index].comment)
            }
        }
    }
}

//struct ServiceEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceEditView()
//    }
//}
