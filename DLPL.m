% This script illustrate how a deep learning system (Alexnet) interact
% with a psychophysical staircase program.

%   fname is mat file name to save result. 
%   startContrast is start contrast for staircase. 
%   corner is either 'NW' or 'NE', defining the diagonal.
%   referenceOrientation is the refence orientation in this block,choose
%   -35 or 55
%   noiseLevel is the noise contrast (0 to 1).
% 
% Training program using four staircases (2/1 and 3/1 at two locations).
% 
% NoiseGabor2('sj1_block1', [0.2 0.3], 'NW', 55 ,1) will use highest noise, the
% stimulus will be at NW or SE corner, the start contast will be 0.2 and
% 0.3 for 2/1 and 3/1 staircases, the reference orientation is 55 deg and the result will be saved to
% sj1_block1.mat.
%% set up some stim parameters
cl;
% ========== parameters you want to change ==========
fname          ='junk_block1'; 
p.noiseLevel   = 0;  %0 ~ 7
p.corner       ='NE'; 
p.startContrast=[0.9 0.9];
% =========================================

p.viewdistance = 58;%cm, for saving purpose
p.screenheight = 30;%cm, for saving purpose
p.screenRect = [0 0 600 600];%width,height
p.offset = 81;
p.stimradius = 1.5;%1.5deg, use deg here to create gabor
p.stimsize = 60; % pixel
p.rAngle = 55; % reference angle, -35 or 55
p.dAngle = 12; % 5 high precision, 12 for low precision

p.sf = 2; % spatial frequency
p.stimradius = 1.5;%1.5deg, use deg here to create gabor
p.sigma  = 0.4; % use deg, for creating gabor

p.factor = 2; % noise pixel size
p.nTrial =[76 84]; % for 2/1 and 3/1 staircases, 
% trial setting
p.nTrials=sum(p.nTrial)*2; % total, one run should be 320 trials
p.rseed=ClockRandSeed; % set random number generator


%% setup stimulus
mN=round(p.stimsize/p.factor); % # of noise pixels, This is useful
% derive stim location
drect=CenterRect([0 0 p.stimsize p.stimsize],p.screenRect);
if strcmpi(p.corner(1:2),'NE')
    r=OffsetRect(drect,p.offset,-p.offset); % p.screenRect of northeast quadrant location
elseif strcmpi(p.corner(1:2),'NW')
    r=OffsetRect(drect,-p.offset,-p.offset);
elseif strcmpi(p.corner(1:2),'SE')
    r=OffsetRect(drect,p.offset,p.offset);
elseif strcmpi(p.corner(1:2),'SW')
    r=OffsetRect(drect,-p.offset,p.offset);
end
[x,y]=meshgrid(linspace(-p.stimradius,p.stimradius,p.stimsize));
gabor1=sind(360*p.sf*(x*cosd(p.rAngle-p.dAngle)+y*sind(p.rAngle-p.dAngle))); %-1~1
gabor2=sind(360*p.sf*(x*cosd(p.rAngle+p.dAngle)+y*sind(p.rAngle+p.dAngle))); %-1~1
gabor1=gabor1.*exp(-((x.^2+y.^2)/2/p.sigma.^2)); % apply mask?%-1~1
gabor2=gabor2.*exp(-((x.^2+y.^2)/2/p.sigma.^2)); % apply mask?%-1~1
outCircle=((x.^2+y.^2)>p.stimradius.^2); % circle mask
tex=zeros(1,2); % prealocate noise tex
%% set up staircases
% Random order for two staircases, up/low location and rotating angle.
% Within each staircase, each angle takes half of trials
iSC=[Expand((1:2)',1,p.nTrial(1)); Expand((3:4)',1,p.nTrial(2))] ; % staircase index 1 to 4
cw=ones(p.nTrials,1);  % clock or counter-clock wise, 1 or -1
% create 2 staircases: 1&2, 2/1; 3&4, 3/1.  1&3, upper location
for i=1:4
    j=(i>2)+1;
    s(i)=staircase('create',[1 j+1],[],p.nTrial(j)); %#ok<*AGROW>
    s(i).stimVal=p.startContrast(j);
    cw(iSC==i)=Shuffle(repmat([-1 1]',p.nTrial(j)/2,1));
end
[iSC, ind]=Shuffle(iSC); % shuffle trials;
cw=cw(ind);

%% record in trial order, not needed for staircase, but for Daphne purpose
% iTrial iSC isUpper isCW contrast ok rt leftKey
rec=nan(p.nTrials,8);
rec(:,1:4)=[(1:p.nTrials)' iSC mod(iSC,2) cw==1];
%    
%% do it
for i=1:p.nTrials
 
    con=s(iSC(i)).stimVal; % obtain contrast for this trial
    
    % generate noise patch, we first try noise level = 0;
    for j=1:2 % make 2 noise tex for each trial
        img=gNoise(mN)*p.noiseLevel/2; % [-0.5*p.noiseLevel/2, 0.5*p.noiseLevel/2]
        img=Expand(img,p.factor);
        img(outCircle) = 0; % circle mask
        noise{j}=img; %
    end
    
    if cw(i)==-1% + 12deg
        %gabortmp = 127*gabor1*con+127; %0~254, we change the contrast,
        % want to add noise?
        gabortmp = 127*(gabor1+noise{1})*con+127; %0~254,we change the contrast
    else
        %gabortmp = 127*gabor2*con+127; %0~254, we change the contrast,
        gabortmp = 127*(gabor2+noise{1})*con+127; %0~254,we change the contrast
    end
    %create a gray image
    
    imgtmp = 127*ones(p.screenRect(4),p.screenRect(3));
    
    
    
    
    % put gabor on gray background
    imgtmp(r(2)+1:r(4),r(1)+1:r(3))=gabortmp;
    imgtmp=uint8(imgtmp);
    
    %% ================= This section is for DL model======
    % imgtmp is the image to provide to Alexnet. Then Alexnet should make a
    % choice here. 1:counterclockwise rotated;2:clockwise rotated
    % choice = 1 or 2,
    figure;imshow(imgtmp);
    drawnow;
    
    [choice, secs]=WaitTill(KbName({'LeftArrow', 'RightArrow','Escape'})); % for response); % wait for response;
    
    choice

    close all;
    %% =================
    
    % collect and update staircase
    
    ok = (choice-1)==(cw(i)==1); % correct or not,cw=-1,counterclockwise,cw=1,clockwise
    cw(i)
    ok
    data = [ok, cw(i)==1];
    s(iSC(i)) = staircase('update',s(iSC(i)),data);
    rec(i,5:7) = [con data(1) choice==1];
end % trials loop

%% finish and save data
save(fname,'p','s','rec');  
s=staircase('compute',s,3); % discard some reversals
staircase('plot',s);  % plot the result
for i=1:2
    s1=staircase('compute',s((i-1)*2+(1:2)),3); % compute start val for next block
    p.startVal(i)=s1(1).meanResult(1);
end
fprintf('\n\n The startContrast for next block are [%.3g %3.g]\n',p.startVal);
p.finish=datestr(now);
save(fname,'p','s','rec');        



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
% This returns key index in keys, and key press time from KbCheck.
% It returns empty k if there is no key press.
function varargout=WaitTill(keys)
    [down t kcode] = KbCheck(-1); %#ok read it as early as possbile
    esc=KbName('Escape');
    while ~any(kcode(keys))
        WaitSecs(0.005);
        [down t kcode] = KbCheck(-1); %#ok
        if kcode(esc), error('esc:exit','ESC pressed.'); end
    end
    k=find(kcode(keys),1);
    if nargout, varargout={k t}; end
end

