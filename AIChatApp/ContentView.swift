//
//  ContentView.swift
//  AIChatApp
//
//  Created by John Money on 3/29/23.
//
import OpenAISwift
import SwiftUI
import UIKit

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "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")
    }
    func send(text: String,
              completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, model: .gpt3(.curie), maxTokens: 500, completionHandler: { result in switch result {
        case .success(let model):
            let output = model.choices.first?.text ?? ""
            completion(output)
        case .failure:
            break
        }
            
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(models, id: \.self) {string in
                    Text(string)
                }
                Spacer()
                
                HStack {
                    TextField("Ask Money!....", text: $text)
                    Button("-->") {
                        ask()
                    }
                    
                }
            }
            .onAppear {
                viewModel.setup()
            }
            .padding()
        }
    }
    func ask() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append("Me: \(text)")
        viewModel.send(text: text) {response in
            DispatchQueue.main.async {
                self.models.append("MONEY: "+response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
