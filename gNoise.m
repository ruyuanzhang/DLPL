% return gaussian noise image within [-0.5 0.5]
function img=gNoise(sz)
    img=randn(sz);
    while 1
        out=abs(img(:))>3; nout=sum(out);
        if nout==0, break; end
        img(out)=randn(nout,1);
    end
    img=img/6; % [-0.5 0.5]
end