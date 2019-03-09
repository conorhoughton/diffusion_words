

function discount(freq::Float64)
    min((sqrt(freq/0.001)+1.0)*0.001/freq,1.0)
    1/freq
    1.0
end


mutable struct Proximity_word
    word::String
    frequency::Float64
    proximity::Vector{Float64}
    word_i::Int64
end

mutable struct Each_word
    word::String
    frequency::Float64
end

mutable struct All_words
    word_list::Vector{String}
    word_list_dict::Dict{String,Int64}
    target_words::Vector{Proximity_word}
    target_word_dict::Dict{String,Int64}
end


function pretty_print_matrix(matrix::Array{Float64})
    this_size=size(matrix)
    for j in 1:this_size[2]
        for i in 1:this_size[1]
            print(round(matrix[i,j],5))
            print(" ")
        end
        print("\n")
    end
    println("\n")
end
