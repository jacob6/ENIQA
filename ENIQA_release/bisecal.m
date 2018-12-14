function e = bisecal(im)
[row,col]=size(im);
im=im+1;
f=zeros(256,256);
p = im;
for i=2:row-1
    for j=2:col-1
        p(i,j)=(im(i+1,j)+im(i,j+1)+im(i-1,j)+im(i,j-1)+im(i+1,j+1)+im(i+1,j-1)+im(i-1,j+1)+im(i-1,j-1))/8;
        
        x=im(i,j);
        y=round(p(i,j));
        f(x,y)=f(x,y)+1;
    end
end
f=f./(row*col);

result=0;  
for m=1:256;  
    for  n=1:256;  
        if f(m,n)==0;  
            result=result;  
        else  
            result=result-f(m,n)*log2(f(m,n));  
        end 
    end  
end  
e = result;
end
