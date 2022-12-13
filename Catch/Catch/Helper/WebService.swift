//
//  WebService.swift
//  Catch
//
//  Created by Ilyes Djari on 23/11/2022.
//

import Foundation

struct Webservice {

    static func getDataFromWebservice(completion: @escaping ([Pokemon]?) -> Void) async {
                
        for _ in 1...3 {
            let number = Int.random(in: 0..<100)
                let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(number)")!
                let task = URLSession.shared.dataTask(with: url) {
                  (data: Data?, response: URLResponse?, error: Error?) -> Void in

                  if let jsonData = data
                  {
                    let decoder = JSONDecoder()
                    do {
                      let yourPokemons  = try decoder.decode(Pokemon.self, from: jsonData)
                        print(yourPokemons)

                      completion([yourPokemons])
                    } catch {
                      print(error.localizedDescription)
                      print(String(describing: error))
                      completion(nil)
                    }
                  }
                }
                task.resume()
              }
    }
    
    static func getPokemonFromWebservice(chosenPokemon: String,completion: @escaping ([Welcome]?) -> Void) async {

    
    let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(chosenPokemon)")!
    let task = URLSession.shared.dataTask(with: url) {
      (data: Data?, response: URLResponse?, error: Error?) -> Void in

      if let jsonData = data
      {
        let decoder = JSONDecoder()
        do {
          let thePokemon  = try decoder.decode(Welcome.self, from: jsonData)

          completion([thePokemon])
        } catch {
          print(error.localizedDescription)
          print(String(describing: error))
          completion(nil)
        }
      }
    }
    task.resume()
  }
}



