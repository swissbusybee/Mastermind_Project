module MasterMind

  ENCOURAGE_PHRASE = ["Give me your best shot", "Shoot a guess",
    "Lets try to break it", "Show me your hacking skill bro",
    "Try me"]

  COMPUTER_PHRASE = ["That was easy, try harder", "Is that all you got?",
    "Easy Peasy","Winner winner, chicken dinner"]

    def generate_random_num
      rand(9).to_s
    end

    def generate_code
      code = String.new
        while code.size < 4
          digit = generate_random_num
          if !code.include? digit
            code << digit
          end
        end
      code
    end

    def colorize(text, color)
      "\e[#{color == 'red' ? 31 : 32}m#{text}\e[0m"
    end

  end

  class Screen
    include MasterMind
    def greeting
      puts "Game Rules"
      puts " "
      puts "As the Codemaker: your goal is to set"
      puts "mystery code so cunning that it will"
      puts "keep your opponent guessing for as"
      puts "long as possible."
      puts " "
      puts "As the Decoder: you must break the"
      puts "secret code in the fewest number of guesses but you"
      puts "but you have 4 rounds to crack the code."
      puts " "
      puts "The code contains 4 digits between 0 and 9"
      puts "for example: 1354"
      puts " "
      puts "if you guessed a number and the position"
      puts "the number will upear in green color"
      puts "like so: #{colorize('1','green')} _ _ _ "
      puts " "
      puts "if you guessed the number but not the"
      puts "position, the number will upear white"
      puts "color like so: #{colorize('1','green')} 4 _ _ "
      puts " "
      puts "if you guessed the wrong number"
      puts "the number will appear red"
      puts "like so: #{colorize('1','green')} 4 #{colorize('0','red')} #{colorize('2','red')}"
      puts "\n"
    end
  end

  class Decoder
    include MasterMind
    def initialize;
    end

    def get_clue(secret_code)
      clue = 0
      arr = secret_code.split('')
      arr.each {|num| clue += num.to_i}
      clue.to_s
    end

    def set_guess
      puts "#{ENCOURAGE_PHRASE[rand(4)]}, give me 4 digit"
      guess = gets.chomp
      guess
    end

    def is_cracked?(secret_code, player_guess)
      secret_code == player_guess
    end

    def output_guess(secret_code, player_guess)
      p_arr = player_guess.split('')
      s_code_arr = secret_code.split('')
      correct_count = 0
      output = ''

      p_arr.each_with_index {|digit, i|
        if digit.to_i == secret_code[i].to_i
          output << "#{colorize(digit, 'green')} "
          correct_count += 1
        elsif s_code_arr.include? digit
          output << "#{digit} "
        else
          output << "#{colorize(digit, 'red')} "
        end
      }
      if correct_count < 4
        puts output
      else
        puts "You cracked the code #{output}!!!"
        puts "\n"
      end
    end

  end

  class Comp
    include MasterMind
    def initialize;
    end

    def first_guess
      guess = generate_code
      guess
    end

    def handle_correct(memory,guess)
      update_guess = guess
      memory[:correct].each_with_index {|elem, i|
        update_guess[i] = elem if elem != "*"
      }
      update_guess
    end

    def handle_wrong_i(memory,guess)
      update_guess = guess
      loop = memory[:wrong_i].count {|elem| elem != "-"}

      loop.times {
        update_guess.each_with_index {|elem, i|
          if elem == ''
            memory[:wrong_i].each_with_index {|e, j|
              if e != '-' && j != i
                update_guess[i] = e
                memory[:wrong_i][j] = '-'
              end
            }
          end
        }
      }
      update_guess
    end

    def handle_wrong(memory,guess)
      update_guess = guess

      guess.each_with_index {|elem, i|
        if elem == ""
          ran_num = generate_random_num
          while memory[:wrong].include?(ran_num) || guess.include?(ran_num)
            ran_num = generate_random_num
          end
          update_guess[i] = ran_num
        end
      }
      update_guess
    end

    def guess(memory)
      new_guess = ['','','','']
      if memory[:correct].any? {|elem| elem != '*'}
        new_guess = handle_correct(memory,new_guess)
        new_guess = handle_wrong_i(memory,new_guess)
        new_guess = handle_wrong(memory,new_guess)
      else
        new_guess = handle_wrong_i(memory,new_guess)
        new_guess = handle_wrong(memory,new_guess)
      end
      new_guess.join('')
    end

    def guessed?(guess, s_code)
      guess == s_code
    end

    def update_correct(memory, digit, index)
      memory[:correct][index] = digit
    end

    def update_wrong_index(memory, digit, index)
      memory[:wrong_i][index] = digit
    end

    def update_wrong(memory, digit, index)
      memory[:wrong] << digit
    end

    def check_guess(guess, secret_code , index, memory)
      if  guess[index] == secret_code[index]
          update_correct(memory, guess[index], index)
         return [guess[index],'green']
      elsif secret_code.include? (guess[index])
          update_wrong_index(memory, guess[index], index)
          return [guess[index],'white']
        else
          update_wrong(memory, guess[index], index)
          return [guess[index],'red']
      end
    end


    def output_guess(secret_code,new_guess, memory)
      c_arr = new_guess.split('')
      s_code_arr = secret_code.split('')
      output = ''
      c_arr.each_with_index {|digit, i|
        check = check_guess(c_arr,s_code_arr,i, memory)
        case check[1]
        when 'green' then output << "#{colorize(check[0],check[1])} "
        when 'red' then output << "#{colorize(check[0],check[1])} "
        else  output << "#{check[0]} "
        end
      }
      puts output
    end
  end


  def play_decoder
    include MasterMind
    player = Decoder.new
    secret_code = generate_code
    guessed = false
    5.times {
      guess = player.set_guess
      player.output_guess(secret_code, guess)
      guessed = player.is_cracked?(secret_code, guess)
      break if guessed
    }
    if guessed
      puts "Nice Play"
      puts "\n"
    else
      puts "Better luck next time"
      puts "\n"
    end
      puts "Another Round ? Y / N"
      answer = gets.chomp.upcase
      if answer == 'Y'
        game
      end
  end

  def play_codemaker
    include MasterMind
    comp = Comp.new

    puts "Set your code : "
    secret_code = gets.chomp
    puts "\n"

    comp_guess = comp.first_guess
    memory = {
      correct: ['*','*','*','*'],
      wrong_i: ['-','-','-','-'],
      wrong: []
    }

    guessed = false
    comp.output_guess(secret_code, comp_guess, memory)
      puts "\n"
    5.times {
      comp_guess = comp.guess(memory)
      comp.output_guess(secret_code, comp_guess, memory)
      puts "\n"
      guessed = comp.guessed?(comp_guess,secret_code)
      break if guessed
    }

    if guessed
      puts "#{COMPUTER_PHRASE[rand(4)]}"
      puts "\n"
    else
      puts "WHOMP WHOMP, I'll try harder next time"
      puts "\n"
    end

    puts "Another Round ? Y / N"
      answer = gets.chomp.upcase
      if answer == 'Y'
        game
      end
  end


  def game
    screen = Screen.new
    screen.greeting
    puts "Select the mode you want to Play ? Decoder (1) / Codemaker (2)"
    answer = gets.chomp
    case answer
    when '1'
      puts "Playing as decoder"
      puts "\n"
      play_decoder
    when '2'
      puts "Playing as codemaker"
      puts "\n"
      play_codemaker
    end
  end

  ###start here###
  game
