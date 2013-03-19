module RandomStrings
  def urlsafe_randstr
    randstr_array =  [('a'..'z'), ('A'..'Z'), ('0'..'9'), ['-', '_']].map{|i| i.to_a}.flatten
    randstr  =  (0...16).map{ randstr_array[rand(randstr_array.length)] }.join
    randstr
  end
  
  def password_randstr
    randstr_array =  [('a'..'z'), ('A'..'Z'), ('0'..'9')].map{|i| i.to_a}.flatten
    randstr  =  (0...8).map{ randstr_array[rand(randstr_array.length)] }.join
    randstr
  end
end
