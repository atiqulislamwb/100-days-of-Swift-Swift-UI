//
//  ContentView.swift
//  WordScramble
//
//  Created by Atiqul Islam on 8/2/24.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false


    func addNewWord (){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard newWord.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        withAnimation{usedWords.insert(answer, at: 0)}
        newWord = ""
    }
    
    func startGame(){
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String (contentsOf: startWordUrl){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Couldn't load file")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        NavigationStack {
               List {
                   Section {
                       TextField("Enter your word", text: $newWord)
                           .autocapitalization(.none)
                           .autocorrectionDisabled()
                   }

                   Section {
                       ForEach(usedWords, id: \.self) { word in
                           HStack (spacing: 10){
                               Image(systemName: "circle")
                               Text(word)
                               
                           }
                       }
                   }
               }
               .navigationTitle(rootWord)
               .onSubmit(addNewWord)
               .onAppear(perform:  startGame)
               .alert(errorTitle, isPresented: $showingError) {
                   Button("OK") { }
               } message: {
                   Text(errorMessage)
               }
           }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
