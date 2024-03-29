//
//  MainView.swift
//  ExerciseRecordApp
//
//  Created by 염성필 on 2023/03/19.
//
import SwiftUI



// Todo - 서치 뷰에 focusState 설정하기

struct MainView: View {
    
    private var mainCategoies: [Color] = [.red, .yellow, .mint, .gray, .green]
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entity.date, ascending: false)]) private var datas: FetchedResults<Entity>
    @State private var isFullCoverSheet: Bool = false
    @State private var searchQuery: String = ""
    
    
    var filter : FetchedResults<Entity> {
       
        return searchQuery.isEmpty ? datas : filterSearchQuery()
    }
    
    func filterSearchQuery() -> FetchedResults<Entity> {
        let filter = searchQuery
        let predicate = NSPredicate(format: "title = %@", filter)
        datas.nsPredicate = predicate
        print("datas - \(datas.count)")
        return datas
    }
   
    var body: some View {
        
        
        NavigationView {
            ScrollView(showsIndicators: false) {
                
                LazyVStack(spacing: 15) {
                    ForEach(datas, id: \.self) { data in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                
                                .stroke(mainCategoies[Int(data.colorIndex)], lineWidth: 1)
                                .frame(height: 80)
                                
                                    HStack {
                                        VStack(alignment: .leading, spacing: 10) {
                                            
                                            HStack {
                                                if let data = data.date {
                                                    
                                                    let dateFromCoreData: Date = data
                                                    let kDate = dateFromCoreData.toKSTString()
                                                    
                                                    
                                                    Text("\(kDate)")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing, 20)
                                                }
                                                
                                                Text(data.category ?? "")
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(mainCategoies[Int(data.colorIndex)])
                                                            .frame(width: 45, height: 25, alignment: .center)
                                                    }
                                                    .tint(.white)
                                                
                                            }
                                            
                                            Text(data.title ?? "")
                                                .font(.title3)
                                                .foregroundColor(.black)
                                            
                                        }
                                        Spacer()
                                        Rectangle()
                                            .fill(.white)
                                            .opacity(0.001)
                                        Button {
                                            updateIsToggle(target: data)
                                        } label: {
                                            Image(systemName : data.isSuccess ? "checkmark.square.fill" : "checkmark.square")
                                        }

                                        
                                        HStack {
                                            Rectangle()
                                                .cornerRadius(12, corners: [.bottomRight, .topRight])
                                                .foregroundColor(mainCategoies[Int(data.colorIndex)])
                                        }
                                        .frame(width: UIScreen.main.bounds.width * 0.05)
                                    }
                                    .padding(.leading, 10)
                                
                        }
                        .opacity(data.isSuccess ? 0.3 : 1.0)
                        .fullScreenCover(isPresented: $isFullCoverSheet) {
                            PlayView(data: data)
                        }
                    }
                    .onTapGesture {
                        isFullCoverSheet.toggle()
                    }
                }
                .padding()
            }
            .navigationTitle("운동일지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddView()
                    } label: {
                        Image(systemName: "plus")
                            .tint(.black)
                    }
                    
                }
            }
            .searchable(text: $searchQuery, placement: .navigationBarDrawer, prompt: "검색어를 입력해주세요.")
            .onSubmit(of: .search) {
                print("\(searchQuery)")
            }
            .onChange(of: searchQuery) { newValue in
                search(text: newValue)
            }
        }
    }
    
    private func search(text: String) {
        if text.isEmpty {
            datas.nsPredicate = nil
        } else {
            let titlePredicate: NSPredicate = NSPredicate(format: "title contains %@", text)
            let contentPredicate: NSPredicate = NSPredicate(format: "content contains %@", text)
            datas.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
        }
    }
    
    func updateIsToggle(target: Entity) {
        withAnimation {
            target.isSuccess.toggle()
            target.exerciseClicked.toggle()
            try? viewContext.save()
        }
    }
}




struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


