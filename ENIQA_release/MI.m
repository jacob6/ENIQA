function [D]=MI(A,B)
A=im2double(A); 
B=im2double(B); 

HA=entropy(A);
HB=entropy(B);

[m,n,~]=size(A);     
a = double(A)*255+1;
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
HAB = -en;  
D = HA+HB-HAB;  
end
