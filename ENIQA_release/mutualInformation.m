function [D,F,L]=mutualInformation(A)
%% The code might look a little redundant but it works fairly well

A=im2double(A); 
[m,n,q]=size(A); 
R=A(:,:,1); 
G=A(:,:,2); 
B=A(:,:,3); 
HR=entropy(R);
HG=entropy(G);
HB=entropy(B);


[m,n,t]=size(R);     
a = double(R)*255+1;
b = double(G)*255+1;
hab=zeros(256,256);  
for i = 1:m  
    for j = 1:n  
        index_x=round(a(i,j));
        index_y=round(b(i,j));
        hab(index_x,index_y)=hab(index_x,index_y)+1;  
    end  
end  
p = hab./(m*n);
en = 0.;
for i = 1:256  
    for j = 1:256  
        if p(i,j)~=0  
           en = en+p(i,j)*log2(p(i,j)); 
        end  
    end  
end  
HRG = -en;  
D = HR+HG-HRG;  

a = double(R)*255+1;
b = double(B)*255+1;
hab=zeros(256,256);  
for i = 1:m  
    for j = 1:n  
        index_x=round(a(i,j));
        index_y=round(b(i,j));
        hab(index_x,index_y)=hab(index_x,index_y)+1;  
    end  
end  
p = hab./(m*n);
en = 0.;
for i = 1:256  
    for j = 1:256  
        if p(i,j)~=0  
           en = en+p(i,j)*log2(p(i,j));
        end  
    end  
end  
HRB = -en;  
F = HR+HB-HRB;  

a = double(G)*255+1;
b = double(B)*255+1;
hab=zeros(256,256);  
for i = 1:m  
    for j = 1:n  
        index_x=round(a(i,j));
        index_y=round(b(i,j));
        hab(index_x,index_y)=hab(index_x,index_y)+1;  
    end  
end  
p = hab./(m*n);
en = 0.;
for i = 1:256  
    for j = 1:256  
        if p(i,j)~=0  
           en = en+p(i,j)*log2(p(i,j));
        end  
    end  
end  
HGB = -en;  
L = HG+HB-HGB;  
end
