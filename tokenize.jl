

function word_2_all_words(file_name::String,big_c::Int64,word_n::Int64)

    function strip_word(word::SubString)
        replace(lowercase(word),r"\?|,|;|!|\.|\"|\"|-|\(|\)|\_|\]|\[|\'|\*","")
    end


    function calculate_frequencies()
        total=0::Int64
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
                            total+=1
                        end
                    end
                end
            end
        end

        for word in word_list
            word.frequency/=total
        end
      
        word_list
 
    end
    
    word_list=calculate_frequencies()

    sort!(word_list, by= x->x.frequency,rev=true)

    word_total_n=length(word_list)

    word_list_dict=Dict(x.word=>i for (i,x) in enumerate(word_list))

    target_words=[Proximity_word(x.word,x.frequency,zeros(Float64,word_total_n),word_list_dict[x.word]) for x in word_list[1:word_n]]

    target_word_dict=Dict(x.word=>i for (i,x) in enumerate(target_words))
    
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
                current_word_index=mod(point-big_c,window_n)+1
                current_word=moving_window[current_word_index]
                if haskey(target_word_dict,current_word)
                    index_in_target_list=target_word_dict[current_word]
                    for (i,window_word) in enumerate(moving_window)
                        if i!=current_word_index
                            index_in_word_list=word_list_dict[window_word]
                            target_words[index_in_target_list].proximity[index_in_word_list]+=discount(word_list[index_in_word_list].frequency)
                        end
                    end
                end
                point=(point+1)%window_n
            end
        end
    end
    
    for this_word in target_words
        this_word_i=word_list_dict[this_word.word]
        this_word.proximity[this_word_i]=0.0
        sum_this_word=sum(this_word.proximity)
        this_word.proximity/=sum_this_word
    end

    close(f)

    All_words([this_word.word for this_word in word_list],word_list_dict,target_words,target_word_dict)
    
end
