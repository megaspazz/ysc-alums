module RandomStrings
  def urlsafe_randstr
    randstr_array =  [('a'..'z'), ('A'..'Z'), ('0'..'9'), ['-', '_']].map{|i| i.to_a}.flatten
    randstr  =  (0...15).map{ randstr_array[rand(randstr_array.length)] }.join
    randstr
  end
end
