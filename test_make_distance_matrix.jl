
include("utilities.jl")
include("tokenize.jl")
include("make_distance_matrix.jl")

#file_name="the_snowball_effect.txt"
#file_name="middlemarch.txt"
file_name="all.txt"

big_c=5::Int64

word_n=5000::Int64

all_words=word_2_all_words(file_name,big_c,word_n)

similarity_matrix=make_similarity_matrix(all_words)

knn=15

similarity_matrix=prune_similarity_matrix(similarity_matrix,knn)

laplace=make_laplace_matrix(similarity_matrix)

(e,x)=eig(laplace)

#eigenvectors x[:,i]


eigen_s=Eigen[]

for i in 1:word_n
    push!(eigen_s,Eigen(real(e[i]),[real(comp) for comp in x[:,i]]))
end

sort!(eigen_s, by=e->e.eigen_val)

save_eigens(eigen_s,all_words,"test_save_eigen_discount.dat")




# closest_words=(1,2)
# biggest_similarity=0.0::Float64

# (word_n,~)=size(similarity_matrix)

# for i in 1:word_n
#     for j in i+1:word_n
#         if similarity_matrix[i,j]>biggest_similarity
#             biggest_similarity=similarity_matrix[i,j]
#             closest_words=(i,j)
#         end
#     end
# end

# println(all_words.target_words[closest_words[1]].word," ",all_words.target_words[closest_words[2]].word)

# furthest_words=(1,2)

# smallest_similarity=similarity_matrix[1,2]::Float64

# for i in 1:word_n
#     for j in i+1:word_n
#         if similarity_matrix[i,j]<smallest_similarity
#             smallest_similarity=similarity_matrix[i,j]
#             furthest_words=(i,j)
#         end
#     end
# end

# println(all_words.target_words[furthest_words[1]].word," ",all_words.target_words[furthest_words[2]].word)

