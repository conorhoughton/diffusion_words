
function corr(a::Vector{Float64},b::Vector{Float64})
    1/norm(a-b)
#    dot(a,b)#/(norm(a)*norm(b))
end

function jsd(a::Vector{Float64},b::Vector{Float64})

    function kl(a,m)
        d=0
        for i in 1:length(a)
            if a[i]!=0
                d+=a[i]*log(2,m[i]/a[i])
            end
        end
        -d
    end
        
    m=(a+b)/2

    jsdiv=0.5*(kl(a,m)+kl(b,m))

    1.0-sqrt(jsdiv)

end


function leave_out_jsd(a::Vector{Float64},b::Vector{Float64},word_a::Int64,word_b::Int64)

    function kl(a,m,prob_a,prob_m)
        d=0
        for i in 1:length(a)
            if a[i]!=0 && i!=word_a && i!=word_b
                d+=(a[i]/(1-prob_a))*log(2,m[i]*(1-prob_a)/(a[i]*(1-prob_m)))
            end
        end
        -d
    end

    prob_a=a[word_a]+b[word_a]
    prob_b=a[word_b]+b[word_b]

    m=(a+b)/2
    prob_m=(prob_a+prob_b)/2
                    
    jsdiv=0.5*(kl(a,m,prob_a,prob_m)+kl(b,m,prob_b,prob_m))
    
    1.0-sqrt(jsdiv)

end

function one_over_l2(a::Vector{Float64},b::Vector{Float64})
    1/norm(a-b)
end


function make_similarity_matrix(all_words::All_words)
    word_n=length(all_words.target_words)
    
    distance_metric=zeros(word_n,word_n)

    for i in 1:word_n-1
        for j in i+1:word_n
            word_i=all_words.target_words[i].word_i
            word_j=all_words.target_words[j].word_i
            
            d=leave_out_jsd(all_words.target_words[i].proximity,all_words.target_words[j].proximity,word_i,word_j)
            
            distance_metric[i,j]=d
            distance_metric[j,i]=d
            
        end
    end
    
    distance_metric

end

function prune_similarity_matrix(similarity_matrix::Array{Float64},knn_n::Int64)
    (word_n,~)=size(similarity_matrix)
    
    for row in 1:word_n
        this_row=sort(similarity_matrix[:,row],rev=true)
        cut_off=this_row[knn_n]
        for column in 1:word_n
            if similarity_matrix[column,row]<cut_off
                similarity_matrix[column,row]=0.0
            end
        end
        
    end


    for j in 1:word_n
        for i in 1:word_n
            if similarity_matrix[i,j]==0 && similarity_matrix[j,i]!=0
                similarity_matrix[i,j]=similarity_matrix[j,i]
            end
        end
    end

    similarity_matrix

end

function make_laplace_matrix(similarity_matrix::Array{Float64})

    laplace=zeros(Float64,word_n,word_n)
    
    for j in 1:word_n
        row_sum=sum(similarity_matrix[:,j])
        laplace[j,j]=1.0
        for i in 1:word_n
            if i!=j
                if similarity_matrix[i,j]!=0
                    laplace[i,j]=-similarity_matrix[i,j]/row_sum
                end
            end
        end
    end

    laplace
    
end
