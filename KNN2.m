function RNNname=KNN2(M,m,n,K,ith,sss)  

d=zeros(m,m);  
c=zeros(m,m);  
for i=1:m-1
    for j=i:m
        for k=1:n
            if (M(i,k)=='a' && M(j,k)=='a')||(M(i,k)=='t' && M(j,k)=='t')
                c(i,j)=c(i,j)+1;
            end
            if (M(i,k)=='a' && M(j,k)=='t')||(M(i,k)=='t' && M(j,k)=='a')
                d(i,j)=d(i,j)+1;
            end
        end
    end
end
    
S=c-d; 

SS=S'+S-diag(diag(S)); 

[~,I]=sort(SS,2,'descend'); 
knn=I(:,1:K);

NN=zeros(m,m);
for i=1:m
    for j=1:K
        NN(i,knn(i,j))=1;
    end
end

RNN=NN';

RNNname=[num2str(ith),sss,'RNN.tab'];
fid_RNN=fopen(RNNname,'w+');
for i=1:m     
    for j=1:m
        if RNN(i,j)==1
            fprintf(fid_RNN,'%d ',j);
        end
    end
    fprintf(fid_RNN,'\n');
end
fclose(fid_RNN);
