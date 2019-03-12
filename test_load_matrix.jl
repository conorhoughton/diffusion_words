 
include("utilities.jl")

filename="test_save_eigen_discount.dat"

vector_n=20

(words,eigens)=load_eigens(filename,1+vector_n)

struct Word_vector
    word::String
    position::Vector{Float64}
end


word_vectors=Vector{Word_vector}()

for (i,word) in enumerate(words)
    position=zeros(Float64,vector_n)
    for j in 2:vector_n+1
        position[j-1]=(1-eigens[j].eigen_val)*eigens[j].eigen_vec[i]
    end
    push!(word_vectors,Word_vector(word,position))
end


word_vector_dict=Dict(x.word=>i for (i,x) in enumerate(word_vectors))


function find_closest(word_vectors,position,current_word)

    function cosine(a::Vector{Float64},b::Vector{Float64})
        dot(a,b)/(norm(a)*norm(b))
    end

    first=1
    if first==position
        first+=1
    end
    
#    closest=cosine(position,word_vectors[first].position)
    closest=norm(position-word_vectors[first].position)
    closest_i=first
    
    for (i,e) in enumerate(word_vectors)
        if i != current_word
            this_d=norm(position-e.position)
            if this_d<closest
                closest=this_d
                closest_i=i
            end
        end
    end
    
    word_vectors[closest_i].word
    
end


test=word_vectors[word_vector_dict["him"]].position-word_vectors[word_vector_dict["he"]].position+word_vectors[word_vector_dict["i"]].position

println(find_closest(word_vectors,test,-1))


test=word_vectors[word_vector_dict["her"]].position-word_vectors[word_vector_dict["she"]].position+word_vectors[word_vector_dict["he"]].position

println(find_closest(word_vectors,test,-1))

test=word_vectors[word_vector_dict["me"]].position-word_vectors[word_vector_dict["i"]].position+word_vectors[word_vector_dict["he"]].position

println(find_closest(word_vectors,test,-1))


test=word_vectors[word_vector_dict["his"]].position-word_vectors[word_vector_dict["he"]].position+word_vectors[word_vector_dict["she"]].position

println(find_closest(word_vectors,test,-1))

test=word_vectors[word_vector_dict["wife"]].position-word_vectors[word_vector_dict["his"]].position+word_vectors[word_vector_dict["her"]].position

println(find_closest(word_vectors,test,-1))

test=word_vectors[word_vector_dict["boy"]].position-word_vectors[word_vector_dict["man"]].position+word_vectors[word_vector_dict["woman"]].position

println(find_closest(word_vectors,test,-1))


test=word_vectors[word_vector_dict["father"]].position-word_vectors[word_vector_dict["man"]].position+word_vectors[word_vector_dict["woman"]].position

println(find_closest(word_vectors,test,-1))


test=word_vectors[word_vector_dict["father"]].position-word_vectors[word_vector_dict["brother"]].position+word_vectors[word_vector_dict["sister"]].position

println(find_closest(word_vectors,test,-1))


test=word_vectors[word_vector_dict["husband"]].position-word_vectors[word_vector_dict["man"]].position+word_vectors[word_vector_dict["woman"]].position

println(find_closest(word_vectors,test,-1))

test=word_vectors[word_vector_dict["run"]].position-word_vectors[word_vector_dict["is"]].position+word_vectors[word_vector_dict["was"]].position

println(find_closest(word_vectors,test,-1))



#for test_n in 1:5000
#    print(word_vectors[test_n].word," ")
#    find_closest(word_vectors,word_vectors[test_n].position,test_n)
#end
