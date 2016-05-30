# require 'open-uri'
# require 'json'

# class GameController < ApplicationController
#   def game
#     @grid = generate_grid(9)

#     # attempt = # need to get a attemp value that i got from home.html
#     # attempt_grid?(attempt, grid)
#     # hash = create_hash(attempt, grid, hash, translation) # do i do this from inside of each method
#     # run_game(attempt, grid, start_time, end_time)
#   end

#   def generate_grid(grid_size)
#   # TODO: generate random grid of letters
#   (0...9).map{ (65 + rand(26)).chr }.join
# end

# def attempt_grid?(attempt, grid)
#   check = attempt.upcase.split("")
#   check.each do |letter|
#     return false if check.count(letter) > grid.count(letter)
#   end
#   return true
# end

# def correct_english
#   word = translation["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
#   # score = attempt.length.fdiv(5) * 1.fdiv(hash[:time])
#   if translation["term0"].nil?
#     return nil
#   else
#     return word
#   end

#   score = attempt.length
#   # return hash.merge(translation: word, score: score, message: "well done")
# end

# def create_hash(attempt, grid, translation)
#   if attempt_grid?(attempt, grid)
#     if translation["Error"] == "NoTranslation"
#     #   return hash.merge(message: "not an english word", translation: nil, score: 0)
#     # else
#     correct_english(attempt)
#   end
# else
#     # return hash.merge(message: "not in the grid", score: 0)
#   end
# end




# def run_game(attempt, grid)
#   # TODO: runs the game and return detailed hash of result
#   hash = {}
#   translation = JSON.parse(open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}").read)
#   # create_hash(attempt, grid, translation)
# end

# def score
#   # start_time = Time.now # as soon as user type something
#   # end_time = Time.now - start_time # when user enter submit

#   # need to check if the word is inside of grid
#   # need to count the word and give a score based on it
#   @grid = params[:grid]
#   letters = params[:query]
#   @score = run_game(letters, @grid)

# end
# end
#
require 'open-uri'
require 'json'

class GameController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @attempt = params[:query]
    @grid = params[:grid].split("")
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @score = run_game(@attempt, @grid, @start_time, @end_time)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end


  def included?(guess, grid)
    the_grid = grid.clone
    guess.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    grid.size == guess.size + the_grid.size
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not in the grid"]
      end
    else
      [0, "not an english word"]
    end
  end


  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end


end
