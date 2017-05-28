require 'byebug'

class Game

  MONSTERS = [{name: "BAT", health: 25, power: 5, loot: {items: {power: 3, dexterity: 3}, exp: 50}}]

  TREASURES = [{items: {power: 3, dexterity: 3}, exp: 50}, {items: {power: 5, dexterity: 5}, exp: 100}]

  def initialize
    @floor = Floor.new
    @character = Character.new
  end

  def play_turn
    @floor.explore(50)
    fight_monster
  end

  def fight_monster
    monster = Monster.new(MONSTERS.sample)

    puts "You ran into a #{monster.name}!"

    while true
      puts "What would you like to do? (attack[1]/run[2])"
      action = gets.chomp
      if action == "1"
        damage = @character.attack_damage
        monster.get_hit(damage)
        puts "You have hit the monster for #{damage}!"
        if monster.over?
          puts "You have defeated the monster!"
          @character.update_character(monster.loot)
          return
        end
      else
        break
      end

      @character.get_hit(monster.power)
      puts "#{monster.name} has hit you for #{monster.power} damage!"
      if @character.over?
        puts "You have died."
        return
      end
    end
  end

  def play
    until @floor.floor_level > 3
      puts "You are on floor #{@floor.floor_name}."
      puts "What would you like to do? (checkstatus[1]/progress[2])"
      action = gets.chomp
      if action == "1"
        puts "Your character is level #{@character.level}, has #{@character.health} health, with #{@character.experience} EXP points."
        puts "Current power level is #{@character.power}, with #{@character.dexterity} dexterity."
      else
        puts ".............Now Progressing.............."
        play_turn
      end
    end

    puts "You have won!"
  end
end

class Floor
  attr_accessor :progress
  attr_reader :floor_level

  FLOOR_LEVELS = %w(Ground B1F B2F B3F B4F Boss)

  def initialize
    @floor_level = 0
    @progress = 0
  end

  def explore(num)
    @progress += num
    if @progress > 100
      @floor_level += 1
      @progress = 0
      puts "You progressed onto the next floor!"
    end
  end

  def floor_name
    FLOOR_LEVELS[@floor_level]
  end
end

class Character
  attr_accessor :health, :power, :dexterity, :experience, :level

  def initialize
    @health = 100
    @power = 10
    @dexterity = 10
    @experience = 0
    @level = 1
  end

  def get_hit(damage)
    @health -= damage
  end

  def over?
    @health <= 0
  end

  def update_character(stuff_hash)
    @power += stuff_hash[:items][:power]
    @dexterity += stuff_hash[:items][:dexterity]
    @experience += stuff_hash[:exp]
    puts "You gained #{stuff_hash[:exp]} EXP, #{stuff_hash[:items][:power]} Power, and #{stuff_hash[:items][:dexterity]} Dexterity!"
    if @experience > 100
      level_up!
      puts "You have leveled up!"
    end
  end

  def level_up!
    @level += 1
    @experience = 0
    @power += 5
    @dexterity += 5
  end

  def attack_damage
    critical = rand(99) + @dexterity
    critical < 90 ? @power : @power * 2
  end
end

class Monster
  attr_reader :name, :loot, :power
  attr_accessor :health

  def initialize(options)
    @name = options[:name]
    @health = options[:health]
    @power = options[:power]
    @loot = options[:loot]
  end

  def get_hit(damage)
    @health -= damage
  end

  def over?
    @health <= 0
  end
end

if $PROGRAM_NAME == __FILE__

  Game.new.play

end
