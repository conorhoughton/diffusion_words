
include("tokenize.jl")

file_name="the_snowball_effect.txt"

big_c=5::Int64

word_n=100::Int64

all_words=word_2_all_words(file_name,big_c,word_n)

println([(this_word.word,this_word.frequency,discount(this_word.frequency)) for this_word in all_words.target_words])
