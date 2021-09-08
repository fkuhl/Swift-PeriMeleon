//
//  MemberMarriesEntryView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 8/31/21.
//

import SwiftUI
import PMDataTypes

struct MemberMarriesEntryView: View {
    @EnvironmentObject var document: PeriMeleonDocument
    @Binding var accumulator: MemberMarriesMemberAccumulator
    @Binding var linkSelection: WorkflowLink?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                ChooseMemberView(caption: "Groom:",
                                    memberId: $accumulator.groomId,
                                    filter: { member in
                                        member.isActive() && member.sex == .MALE && member.maritalStatus == .SINGLE
                                    })
                ChooseMemberView(caption: "Bride:",
                                    memberId: $accumulator.brideId,
                                    filter: { member in
                                        member.isActive() && member.sex == .FEMALE && member.maritalStatus == .SINGLE
                                    })
                DateSelectionView(caption: "Date of wedding:", date: $accumulator.date)
                HStack {
                    Text("New household uses address:")
                    Picker(selection: $accumulator.useGroomsAddress,
                           label: Text("huih?")) {
                        Text("Groom's").tag(true)
                        Text("Bride's").tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    Spacer()
                }
                Text("All dependents of either groom or bride are merged into the new household.")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Member Marries Member - Enter Data")
            }
            ToolbarItem(placement: .primaryAction) {
                saveButton
            }
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
    }

    private var saveButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: editAnimationDuration)) {
                NSLog("MMEV continue")
                publishTheBanns()
            }
        }) {
            Text("Continue").font(.body)
        }
    }
    
    private func publishTheBanns() {
        var groomProblem = false
        var brideProblem = false
        let groom = document.member(byId: accumulator.groomId)
        let groomsHousehold = document.household(byId: groom.household)
        ///Groom must be single. If head of household, household cannot have spouse. (Check inconsistent marital status.)
        groomProblem = groom.maritalStatus != .SINGLE || (accumulator.groomId == groomsHousehold.head && groomsHousehold.spouse != nil)
        let bride = document.member(byId: accumulator.brideId)
        let bridesHousehold = document.household(byId: bride.household)
        /// Bride must be single, and cannot be spouse. (Not covered: is she someone else's spouse?)
        brideProblem = bride.maritalStatus != .SINGLE || accumulator.brideId == bridesHousehold.spouse
        if groomProblem || brideProblem {
            accumulator.phase = .problem(groom: groomProblem, bride: brideProblem)
            return
        }
        var groomsDependents = [ID]()
        if accumulator.groomId == groomsHousehold.head {
            groomsDependents = groomsHousehold.others
        }
        var bridesDependents = [ID]()
        if accumulator.brideId == bridesHousehold.head {
            bridesDependents = bridesHousehold.others
        }
        accumulator.combinedDependents = groomsDependents + bridesDependents
        accumulator.phase = .verification
    }
    
    private var cancelButton: some View {
        Button(action: {
            NSLog("MMEV cancel")
            accumulator.phase = .reset
            linkSelection = nil
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel").font(.body)
        }
    }
}

struct MemberMarriesEntryView_Previews: PreviewProvider {
    static var previews: some View {
        MemberMarriesEntryView(
            accumulator: Binding.constant(MemberMarriesMemberAccumulator()),
            linkSelection: Binding.constant(nil))
            .environmentObject(mockDocument)
    }
}
