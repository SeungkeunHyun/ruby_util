class Robot
  attr_accessor :named , :stored_names , :rl

  def initialize()
    @stored_names = []
  end

  @@rl = "_ABCDEFGHIJKLMNOPQRSTUVWXYZ".chars.to_a

  def name
    @named = ""
    @named << @@rl.sample
    @named << @@rl.sample
    @named << rand(100..999).to_s
    save_name 
    check_name
  end

  def save_name
    @stored_names << @named
  end

  def check_name
    @stored_names.uniq!
  end

  def reset
    @stored_names = Array.new
  end
end