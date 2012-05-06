#!/usr/bin/env ruby
# encoding: UTF-8

# checking arg exist
if ARGV.length < 1 # no args
  puts "No need arg. Exiting..."
  exit(1)
end
#
# checking arg correction
if ARGV[0][0..2].length < 3 # should be more than 2 characters
  puts "Bad umask. Exiting..."
  exit(1)
end

if ARGV[0][0..2].scan(/[^0-7]/).size > 0 # only digits from 0 to 7 
  puts "Bad umask. Exiting..."
  exit(1)
end
#
# "inverse" hash need for convert umask value for next "inverse AND" operation
inv_dec_bin_con = {"0"=>'111', "1"=>'110', "2"=>'101', "3"=>'100', "4"=>'011', "5"=>'010', "6"=>'001', "7"=>'000'}
#
# defaul permissions for dirs & files
def_dir_perm = Array.new(9) {1}
def_file_perm = [1,1,0,1,1,0,1,1,0]
#
# convertion umask value from script arg from dec to bin, for next binary evaluation
uma_bin_prep = []

ARGV[0][0..2].split(//).each do |i|
  uma_bin_prep.push inv_dec_bin_con.fetch(i)
end

uma_bin = uma_bin_prep.join # inverse binary value of umask
#

# evaluation permissions & convertion it to "Human-readable" 
def permTrans(uma_bin, def_perm)
  # need for convert final value from bin to dec
  bin_dec_con = {"111"=>"7", "110"=>"6", "101"=>"5", "100"=>"4", "011"=>"3", "010"=>"2", "001"=>"1", "000"=>"0"} 
  #
  # need for convert final value from bin to letters
  bin_lett_con = {"111"=>'rwx', "110"=>'rw-', "101"=>'r-x', "100"=>'r--', "011"=>'-wx', "010"=>'-w-', "001"=>'--x', "000"=>'---'}
  #
  # evaluation permissions (binary operations)
  def permEva(uma_bin, def_perm)
    uma_perm_bin = []
    n=0
    uma_bin.split(//).each do |j|
      uma_perm_bin.push j.to_i & def_perm[n]
      n = n + 1
    end
    return uma_perm_bin
  end
  #
  #convertion to "Human-readable" 
  perm_bin = []
  perm_lett = []
  permEva(uma_bin, def_perm).join.scan(/.../).each do |k|
    perm_bin.push bin_dec_con[k]
    perm_lett.push bin_lett_con[k]
  end
  #
  perm_bin.join + ' ' + perm_lett.join + "\n" # output values
end
#

print "\ndirectories permissions:\t" + permTrans(uma_bin, def_dir_perm) # operation for evaluation dir permissions
print "files permissions:\t\t" + permTrans(uma_bin, def_file_perm) + "\n" # operation for evaluation file permissions

