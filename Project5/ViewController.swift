//
//  ViewController.swift
//  Project5
//
//  Created by Lucas Rocha on 12/09/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var state = State()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(confirmRestart))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }

        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "state") as? Data{
            let jsonDecoder = JSONDecoder()
            
            do{
                state = try jsonDecoder.decode(State.self, from: savedData)
            }catch{
                print("failed to reload")
            }
            
            tableView.reloadData()
            title = "\(state.currentWord) Score: \(state.score)"
        }else{
            startGame()
        }
    }
    
    func startGame(_ action: UIAlertAction! = nil){
        state.currentWord = allWords.randomElement()!
        title = "\(state.currentWord) Score: \(state.score)"
        state.userWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        state.score = 0
        save()
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(state){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "state")
        } else{
            print("failed to save State")
        }
    }
    
    @objc func confirmRestart(){
        let ac = UIAlertController (title: "Are you sure?", message: "Restart the game changes the word and reset the score", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: startGame))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.userWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = state.userWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    
    func submit(_ answer: String){
        let lowerAnswer = answer.lowercased()
        
        if answer.isEmpty {return}
        
        if isPossible(lowerAnswer){
            if isOriginal(lowerAnswer){
                if isReal(lowerAnswer){
                    state.userWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    state.score += 1
                    title = "\(state.currentWord) Score: \(state.score)"
                    save()
                    return
                } else{
                    showErrorMesage("Word not recognized", "You can't just make them up, you know")
                }
            } else{
                showErrorMesage("Word already used" ,"Be more original!")
            }
        } else{
            showErrorMesage("Word not possible", "You can't spell that word from \(state.currentWord.lowercased()).")
        }
        

    }
    
    func isPossible (_ word: String) -> Bool{
        guard var tempWord = title?.lowercased() else{ return false}
        
        for letter in word{
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            } else{
                return false
            }
        }
        
        return true
    }
    
    func isOriginal (_ word: String) -> Bool{
        if title!.lowercased() == word { return false}
        return !state.userWords.contains(word)
    }
    
    func isReal (_ word: String) -> Bool{
        if word.count < 3 { return false}

        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMesage(_ errorTitle: String, _ errorMessage: String){
        let ac = UIAlertController (title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

