//
//  PokemonViewController.swift
//  Catch
//
//  Created by Ilyes Djari on 22/11/2022.
//

import UIKit
import Kingfisher
import UIImageColors

class PokemonViewController: UIViewController {
    
    

    @IBOutlet weak var pokeSpecie: UILabel!
    @IBOutlet weak var pokeSpecies: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var defenseSlider: UISlider!
    @IBOutlet weak var attackSlider: UISlider!
    @IBOutlet weak var hpSlider: UISlider!
    @IBOutlet weak var pokeWeight: UILabel!
    @IBOutlet weak var pokeHeight: UILabel!
    @IBOutlet weak var pokeSpeed: UILabel!
    @IBOutlet weak var pokeDefense: UILabel!
    @IBOutlet weak var pokeHP: UILabel!
    @IBOutlet weak var pokeAttack: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var pokeImage: UIImageView!
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokeId: UILabel!
    public var chosenPokemon : String!
    public var pokeData: [Welcome]?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
        
    }
    

    
    func initStyle() {
        pokemonName.text = pokeData?[0].name
        let url = URL(string: pokeData?[0].sprites?.frontDefault! ?? "he")
        
        pokeImage.kf.setImage(with: url)  { [self] result in
            switch result {
            case .success(let value):
                let colors = value.image.getColors()
                UIView.animate(withDuration: 1.0) { [self] in
                    background.backgroundColor = colors?.secondary
                    pokeSpecie.text = pokeData![0].abilities![0].ability?.name
                    pokeSpecie.textColor = colors?.background
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        let id = String(pokeData![0].id!)
        pokeId.text = "#\(id)"
        
        pokeHP.text = "\(pokeData![0].stats![0].baseStat!)"
        
        hpSlider.value = Float(pokeData![0].stats![0].baseStat!)
        
        pokeAttack.text = "\(pokeData![0].stats![1].baseStat!)"
        
        attackSlider.value = Float(pokeData![0].stats![1].baseStat!)
        
        pokeDefense.text = "\(pokeData![0].stats![2].baseStat!)"
        
        defenseSlider.value = Float(pokeData![0].stats![2].baseStat!)
        
        pokeSpeed.text = "\(pokeData![0].stats![5].baseStat!)"
        
        speedSlider.value = Float(pokeData![0].stats![5].baseStat!)
        
        pokeHeight.text = "\((pokeData![0].height!)*10) CM"
        pokeWeight.text = "\((pokeData![0].weight!)/10) KG"
        
        pokeSpecies.text = pokeData![0].species?.name
        
    }
}
