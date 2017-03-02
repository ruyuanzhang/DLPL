% NoiseGabor2(fname,startContrast, corner,referenceOrientation,noiseLevel)
%   fname is mat file name to save result. 
%   startContrast is start contrast for staircase. 
%   corner is either 'NW' or 'NE', defining the diagonal.
%   referenceOrientation is the refence orientation in this block
%   noiseLevel is the noise contrast (0 to 1).
% 
% Training program using four staircases (2/1 and 3/1 at two locations).
% 
% NoiseGabor2('sj1_block1', [0.2 0.3], 'NW', 55 ,1) will use highest noise, the
% stimulus will be at NW or SE corner, the start contast will be 0.2 and
% 0.3 for 2/1 and 3/1 staircases, the reference orientation is 55 deg and the result will be saved to
% sj1_block1.mat.

% Based on Jeter et al, Journal of Vision (2009) 9(3):1-13.
% 2010/09   xl  wrote it for Daphne lab
% 2011/04   xl  change from NoiseGabor.m. Two corners with two staircase.
% 2015/08   Ruyuan Zhang changes for video game training study

function NoiseGabor2(fname, startContrast,corner,referenceOrientation, noiseLevel)
if nargin<5 || isempty(noiseLevel), noiseLevel=1; end
if nargin<4 || isempty(referenceOrientation), referenceOrientation=55; end
if nargin<3 || isempty(corner), corner='NW'; end
if nargin<2 || isempty(startContrast), startContrast=[0.9 0.9]; end
if nargin<1 || isempty(fname), fname='junk_block1'; end
tic
% monitor related parameters
p.distance=58; % cm, screen-eye distance
p.screenHeight=30; % cm, height of display region at your resolution
p.monitorGamma=1.871; % set it to your value 
p.btrr=132; % blue to red ratio of your video switcher
p.isBox=0; % 1 for video switcher box, and 0 for card
p.scrID=max(Screen('Screens')); % which screen to display

% stimulus and time parameters
p.radius=1.5; % degree
p.eccentricity=5.67; % degree from target center to fixation
p.rAngle=referenceOrientation; % reference angle, -35 or 55
p.dAngle=12; % 5 high precision, 12 for low precision
p.sf=2; % cycles/degree
p.sigma=0.4; % degree, gaussian sigma
p.factor=2; % noise pixel size
p.dur=0.03; % s, gabor and each noise frame display time
p.isi=0.75; % interval between response and next trial
p.cuedur=[0.25 0.4 0.5 0.75]; % accumlated duration for fixation, cue etc
fixwd=2;  % fixation thickness in pixels
fixsz=10-mod(fixwd,2);  % pixels, fixation cross size
cuesz=[10 6]; % pixels, cue and arrow length
nTrial=[72 84]; % for 2/1 and 3/1 staircases

nTrials=sum(nTrial)*2; % total, *2 for two locations
p.rseed=ClockRandSeed; % set random number generator
p.corner=corner; % record it
p.noiseLevel=noiseLevel;
p.trial2break=ceil(nTrials/3);

KbName('UnifyKeyNames');
keys=KbName({'LeftArrow' 'RightArrow'}); % for response
space=KbName('space');

% Random order for two staircases, up/low location and rotating angle.
% Within each staircase, each angle takes half of trials
iSC=[Expand((1:2)',1,nTrial(1)); Expand((3:4)',1,nTrial(2))] ; % staircase index 1 to 4
cw=ones(nTrials,1);  % clock or counter-clock wise, 1 or -1

% create 4 staircases: 1&2, 2/1; 3&4, 3/1.  1&3, upper location
for i=1:4
    j=(i>2)+1;
    s(i)=staircase('create',[1 j+1],[],nTrial(j)); %#ok<*AGROW>
    s(i).stimVal=startContrast(j);
    cw(iSC==i)=Shuffle(repmat([-1 1]',nTrial(j)/2,1));
end

[iSC ind]=Shuffle(iSC);
cw=cw(ind);

% record in trial order, not needed for staircase, but for Daphne purpose
% iTrial iSC isUpper isCW contrast ok rt leftKey
rec=nan(nTrials,8);
rec(:,1:4)=[(1:nTrials)' iSC mod(iSC,2) cw==1];

try
    % set up screen for video switcher
    PsychVideoSwitcher('SwitchMode', p.scrID, 1, p.isBox); % to gray mode
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit'); 
    PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange'); 
    % PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
    PsychImaging('AddTask','General','EnableVideoSwitcherSimpleLuminanceOutput',p.btrr);
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    [w rect] = PsychImaging('OpenWindow', p.scrID, 0.5, [], 32, 2);
    Screen('BlendFunction',w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    PsychColorCorrection('SetEncodingGamma', w, 1./p.monitorGamma); % set gamma
    HideCursor;
    ifi=Screen('GetFlipInterval',w);
    
    
    ppd=p.distance/p.screenHeight*tand(1)*rect(4); % pixels per degree
    mN=round(p.radius*ppd*2/p.factor); % # of noise pixels
    m=mN*p.factor; % stimulus size in pixels
    nf=round(p.dur/ifi); % number of frames for gabor and noise
    p.dur=nf*ifi; % update the real duration for record
    nf=(nf-0.5)*ifi; % time to wait for Flip

    xyc=rect(3:4)/2; % x and y center of screen, for fixation and precue
    fixxy=[0 0 [-1 1]*fixsz/2; [-1 1]*fixsz/2 0 0]; % fix cross
    cuexy=[0 cuesz([1 2 1 1 1]); 0 cuesz([1 1 1 1 2])]+10;
    drect=CenterRect([0 0 m m],rect);
    d=round(p.eccentricity/sqrt(2)*ppd); % stim offset from center
    if strcmpi(corner(1:2),'NE')
        cuexy=cat(3,[cuexy(1,:); -cuexy(2,:)], [-cuexy(1,:); cuexy(2,:)]);
        drect=[OffsetRect(drect,d,-d); OffsetRect(drect,-d,d)];
    else
        cuexy=cat(3,[-cuexy(1,:); -cuexy(2,:)], [cuexy(1,:); cuexy(2,:)]);
        drect=[OffsetRect(drect,-d,-d); OffsetRect(drect,d,d)];
    end
    
    [x,y]=meshgrid(linspace(-p.radius,p.radius,m));
    gabor=sind(360*p.sf*(x*cosd(p.rAngle)+y*sind(p.rAngle)));
    gabor=gabor.*exp(-((x.^2+y.^2)/2/p.sigma.^2)); % apply mask 
    

    
    gabor=Screen('MakeTexture',w,gabor/2+0.5,[],[],2); % double precision
    outCircle=(x.^2+y.^2>p.radius.^2); % circle mask
    tex=zeros(1,2); % prealocate noise tex
    
    Screen(w,'TextSize',24); Screen(w,'TextFont','Arial');
    str=sprintf(['LEFT/RIGHT keys for counter-clock/clock wise from %g' ...
        ' degree.\n\nPress SPACE to start'], p.rAngle); 
    DrawFormattedText(w, str, 'center','center', 0);
    Screen(w,'Flip'); % show instruction

    WaitTill(space); % wait till SPACE to start
    secs=Screen('Flip',w); % remove instruction
    p.start=datestr(now); % for recrod
    Priority(MaxPriority(w));

    for i=1:nTrials
        up=2-mod(iSC(i),2);
        r=drect(up,:); % stim rect for this trial
        con=s(iSC(i)).stimVal; % contrast for this trial
        for j=1:2 % make 2 noise tex for each trial
            img=gNoise(mN)*noiseLevel+0.5; % [0 1]
            img=Expand(img,p.factor);
            img(outCircle)=0.5; % circle mask
            tex(j)=Screen('MakeTexture',w,img,[],[],2);
        end
        
        %save an image of a noise gebor
        
        
        
        Screen('DrawLines',w,fixxy,fixwd,0,xyc,1); % cross
        vbl=Screen('Flip',w,secs+p.isi,1); % keep cross for next flip
        
        WaitSecs('UntilTime',vbl+p.cuedur(1));
        %audioFeedback(1); % audio cue
        
        if noiseLevel<0.1 % precue for low noise only
            Screen('DrawLines',w,cuexy(:,:,up),1,0,xyc,1); % precue
            Screen('Flip',w,vbl+p.cuedur(2)); % clear buffer
            Screen('DrawLines',w,fixxy,fixwd,0,xyc,1);
            Screen('Flip',w,vbl+p.cuedur(3),1); % remove precue
        end
        
        Screen('DrawTexture',w,tex(1),[],r); % first noise frame
        vbl=Screen('Flip',w,vbl+p.cuedur(4));
        
        Screen('DrawTexture',w,gabor,[],r,p.dAngle*cw(i),1,con); 
        Screen('DrawLines',w,fixxy,fixwd,0,xyc,1);
        t0=Screen('Flip',w,vbl+nf); % signal

        Screen('DrawTexture',w,tex(2),[],r); % second noise frame
        Screen('DrawLines',w,fixxy,fixwd,0,xyc,1);
        vbl=Screen('Flip',w,t0+nf);

        Screen('Flip',w,vbl+nf); % turn off
        Screen('Close', tex); % release memory
        
        [key secs]=WaitTill(keys); % wait for response
        ok=(key-1)==(cw(i)==1); % correct or not
        if ok, audioFeedback(1); end % single beep if correct, no beep if wrong
        
        data=[ok secs-t0 cw(i)==1 up==1];
        s(iSC(i))=staircase('update',s(iSC(i)),data);
        rec(i,5:8)=[con data(1:2) key==1];

        if mod(i,p.trial2break)==0 && i<nTrials % take a break
            str=sprintf(['You have finished %g out of %g trials.\n\n'...
              'Take a break and press SPACE to continue.'],i,nTrials);
            DrawFormattedText(w, str, 'center','center', 0);
            Screen('Flip',w);
            WaitTill(space);
            secs=Screen('Flip',w);
        end
    end % trials loop
    cleanup;
catch ME % error or user exit
    cleanup;
    if ~strcmp(ME.identifier,'esc:exit'), rethrow(ME); end
end


save(fname,'p','s','rec');  

s=staircase('compute',s,3); % discard some reversals
staircase('plot',s);  % plot the result

for i=1:2
    s1=staircase('compute',s((i-1)*2+(1:2)),3); % compute start val for next block
    p.startVal(i)=s1(1).meanResult(1);
end
fprintf('\n\n The startContrast for next block are [%.3g %3.g]\n',p.startVal);
p.finish=datestr(now);
%tme = clock;
%fname=[fname int2str(tme(2)) '|' int2str(tme(3)) '|' int2str(tme(4)) '|',int2str(tme(5))];
save(fname,'p','s','rec');        

function cleanup
    Screen('CloseAll');
    Priority(0);
    PsychVideoSwitcher('SwitchMode', p.scrID, 0, p.isBox); % to color mode
end

end % main

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

% single beep: correct; double beep: wrong
function audioFeedback(correct)
    if nargin<1, correct=1; end
    y=(-200:0.2:200)';
    y=sin(y).*exp(-(y/150).^4);
    fs=22254.54545454;
    if ~correct
        y=[y; zeros(3000,1); y];
        fs=fs*2;
    end
    clear playsnd; sound(y,fs,8);
end

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
