

function strip_word(word::SubString)
    replace(lowercase(word),r"\?|,|;|!|\.|\"|\"|-|\(|\)","")
end

function pretty_print_matrix(matrix::Array{Float64})
    this_size=size(matrix)
    for j in 1:this_size[2]
        for i in 1:this_size[1]
            print(round(matrix[i,j],2))
            print(" ")
        end
        print("\n")
    end
end


function corr(a::Vector{Int64},b::Vector{Int64})
    dot(a,b)/(norm(a)*norm(b))
end


function one_over_l2(a::Vector{Int64},b::Vector{Int64})
    1/norm(a-b)
end


function one_over_l2_normed(a::Vector{Int64},b::Vector{Int64})
    a_sum=sum(a)
    b_sum=sum(b)
    1/norm(a/a_sum-b/b_sum)
end


mutable struct Each_word
    word::String
    frequency::Int64
end

mutable struct Proximity_word
    word::String
    proximity::Array{Int64}
end

word_n=5000
knn_n=10

file_name="great_expectations.txt"

word_list=Each_word[]

open(file_name) do f
    while !eof(f)
        line=readline(f)
        for word in split(line,r" |-")

            word=strip_word(word)

            if word!=""
                index=findfirst(x->x.word==word,word_list)
                if index==0
                    push!(word_list,Each_word(word,1))
                else
                    word_list[index].frequency+=1
                end
            end
        end
    end
end

sort!(word_list, by= x->x.frequency,rev=true)

word_total_n=length(word_list)


all_words=Dict(x.word=>i for (i,x) in enumerate(word_list))

target_words=[Proximity_word(x.word,zeros(Int64,word_total_n)) for x in word_list[1:word_n]]

target_word_dict=Dict(x.word=>i for (i,x) in enumerate(target_words))

big_c=5
window_n=2*big_c+1

moving_window=Vector{String}(window_n)
for i in 1:2*big_c+1
    moving_window[i]=rand(target_words).word
end
    
point=0::Int64

f=open(file_name)

while !eof(f)
    line=readline(f)
    for word in split(line,r" |-")
        word=strip_word(word)
        if word!=""
            moving_window[point+1]=word
            point=(point+1)%window_n
            current_word_index=mod(point-big_c,window_n)+1
            current_word=moving_window[current_word_index]
            if haskey(target_word_dict,current_word)
                current_word_big_index=target_word_dict[moving_window[current_word_index]]
                for (i,word) in enumerate(moving_window)
                    if i!=current_word_index
                        target_words[current_word_big_index].proximity[all_words[word]]+=1
                    end
                end
            end
        end
    end
end

#println([ t.word for t in target_words])

distance_metric=zeros(word_n,word_n)

for i in 2:word_n
    for j in 1:i-1
        d=corr(target_words[i].proximity,target_words[j].proximity)

        distance_metric[i,j]=d
        distance_metric[j,i]=d
    end
end

#println(distance_metric)


for row in 1:word_n
    this_row=sort(distance_metric[:,row],rev=true)
    cut_off=this_row[knn_n]
    for column in 1:word_n
        if distance_metric[column,row]<cut_off
            distance_metric[column,row]=0.0
        end
    end

end

for j in 1:word_n
    for i in 1:word_n
        if distance_metric[i,j]==0 && distance_metric[j,i]!=0
            distance_metric[i,j]=distance_metric[j,i]
        end
    end
end


#pretty_print_matrix(distance_metric)

#lagrange=spzeros(Float64,word_n,word_n)
lagrange=zeros(Float64,word_n,word_n)

for j in 1:word_n
    row_sum=sum(distance_metric[:,j])
    lagrange[j,j]=1.0
    for i in 1:word_n
        if distance_metric[i,j]!=0
            lagrange[i,j]=-distance_metric[i,j]/row_sum
        end
    end
end

#print("\n")

#pretty_print_matrix(lagrange)

(e,x)=eig(lagrange)


println([imag(x)!=0.0 for x in e])



#println(e)

function positive_words(evec,words)
    for (i,w) in enumerate(words)
        if evec[i]>0
            print(w*" ")
        end
    end
    println()
end


function sort_words(evec,words)
    v=collect(zip(evec,words))
    sort!(v,by=x->x[1])
    println([x[2] for x in v])
end

function find_closest(evecs,a_vector)
    function similarity(vector_1,vector_2)
        real(dot(vector_1,vector_2)/(norm(vector_1)*norm(vector_2)))
    end

    dims=size(evecs)[1]

    closest_i=1
    closest_s=similarity(a_vector,evecs[1,:])

    for i in 2:dims
        s=similarity(a_vector,evecs[i,:])
        if s>closest_s
            closest_s=s
            closest_i=i
        end
    end

    closest_i

end


function find_second_closest(evecs,a_vector)
    function similarity(vector_1,vector_2)
        real(dot(vector_1,vector_2)/(norm(vector_1)*norm(vector_2)))
    end

    dims=size(evecs)[1]

    closest_i=1
    closest_s=similarity(a_vector,evecs[1,:])

    second_closest_i=closest_i
    second_closest_s=closest_s
    
    for i in 2:dims
        s=similarity(a_vector,evecs[i,:])
        if s>closest_s
            second_closest_i=closest_i
            second_closest_s=closest_s
            closest_s=s
            closest_i=i
        end
    end

    second_closest_i

end

# kth eig is x[:,k]
# kth word is x[k,:]

#println(norm(x[:,1]))

println(x[:,1])
#println(lagrange*x[:,1])

println([x.word for x in target_words])

v_he=x[target_word_dict["he"],:]
v_his=x[target_word_dict["his"],:]

v_it=x[target_word_dict["it"],:]
v_its=x[target_word_dict["it's"],:]

v_hes_p=v_he+(v_its-v_it)

v_she=x[target_word_dict["she"],:]
v_her=x[target_word_dict["her"],:]

v_i=x[:,target_word_dict["i"]]

v_her_p=v_she+(v_his-v_he)
v_my=v_i+(v_his-v_he)
v_my_2=v_i+(v_her-v_she)

v_hand=x[:,target_word_dict["hand"]]
v_hands=x[:,target_word_dict["hands"]]
v_word=x[:,target_word_dict["word"]]
v_words_p=v_word+(v_hands-v_hand)

println(target_words[find_closest(x,v_her_p)].word)

println(target_words[find_closest(x,v_my)].word)

println(target_words[find_closest(x,v_my_2)].word)

println(target_words[find_closest(x,v_hes_p)].word)

println(target_words[find_closest(x,v_words_p)].word)

println(target_words[find_second_closest(x,v_word)].word)
println(target_words[find_second_closest(x,v_he)].word)
println(target_words[find_closest(x,v_he)].word)

#sort_words(x[:,2],[ t.word for t in target_words])
#sort_words(x[:,3],[ t.word for t in target_words])
#sort_words(x[:,4],[ t.word for t in target_words])


