function [f t] = featureExtract56( imrgb ,scale)
    t=[];
    f=[];
    imdist=rgb2gray(imrgb);

    minWaveLength = 2.4;
    sigmaOnf = 0.55;
    mult = 1.31;
    dThetaOnSigma = 1.10;  
    scaleFactorForLoG = 0.87;
    
    wsize = [8 8];
    
    for i=1:scale        
        sort_t=[];
        
        im=imdist;
        imsa=saliencyMap(im);
        fun0=@sumBlock;
        emat=blkproc(imsa,wsize ,fun0); 
        emat=emat(:)';
        sort_t = sort(emat,'ascend');
        len = length(sort_t);
        tsort=sort_t(ceil(len*0.2):ceil(len*1));
        A=ismember(emat,tsort);
       
        t1=clock;
        im=imdist;
        fun1=@bisecal;
        femat=blkproc(im,wsize,fun1);
        femat=femat(:)';
        femat=femat(A);

        sort_t = sort(femat,'ascend');
        mu= mean(sort_t);
        ske=skewness(sort_t);
        f2=[ mu  ske];        
        a=etime(clock,t1);
        t=[t a];

        t1=clock;
        [f3 f4 f5]=mutualInformation(imrgb);
        a=etime(clock,t1);
        t=[t a];
        
        [rows,cols] = size(imdist);
        LGFilters = logGabors(rows,cols,minWaveLength/(scale^scaleFactorForLoG),sigmaOnf,mult,dThetaOnSigma);
        fftIm = fft2(imdist);
        
        fea=[];
        imggabor={8,1};
        for scaleIndex = 1:2
            for oriIndex = 1:4
                    response = ifft2(LGFilters{scaleIndex,oriIndex}.*fftIm);
                    
                    t1=clock;
                    im=uint8(abs(response));
                    fun1=@bisecal;
                    femat1=blkproc(im,wsize,fun1);
                    femat1=femat1(:)';
                    femat1=femat1(A);

                    sort_t = sort(femat1,'ascend');
                    mu= mean(sort_t);
                    ske=skewness(sort_t);
                    fea2=[ mu ske];        
                    a=etime(clock,t1);
                    t=[t a];
                    imggabor{((scaleIndex-1)*4+oriIndex),1}=im;

                    fea=[fea fea2] ;
            end
        end 
        
        t1=clock;
        imggaborscale{1,1}=imggabor{1,1}+imggabor{2,1}+imggabor{3,1}+imggabor{4,1};
        imggaborscale{2,1}=imggabor{5,1}+imggabor{6,1}+imggabor{7,1}+imggabor{8,1};
        f9=MI(imggaborscale{1,1},imggaborscale{2,1});
        a=etime(clock,t1);
        t=[t a];
        
        t1=clock;
        imggaborori{1,1}=imggabor{1,1}+imggabor{5,1};
        imggaborori{2,1}=imggabor{2,1}+imggabor{6,1};
        imggaborori{3,1}=imggabor{3,1}+imggabor{7,1};
        imggaborori{4,1}=imggabor{4,1}+imggabor{8,1};
        f10=MI(imggaborori{1,1},imggaborori{2,1});
        f11=MI(imggaborori{1,1},imggaborori{3,1});
        f12=MI(imggaborori{1,1},imggaborori{4,1});
        f13=MI(imggaborori{2,1},imggaborori{3,1});
        f14=MI(imggaborori{2,1},imggaborori{4,1});
        f15=MI(imggaborori{3,1},imggaborori{4,1});
        a=etime(clock,t1);
        t=[t a];
        
        % Note that the order of features in this vector is different from 
        % that in the paper
        f=[f f2 f3 f4 f5 fea f9 f10 f11 f12 f13 f14 f15];
        imdist = imresize(imdist,0.5);
        imrgb = imresize(imrgb,0.5); 
    end
end
