% run the whole experiment
% Linfeng Jiang 2022.12.2
prompt = {'Creat your game ID:','Do you have any Game Experience before(1 for yes,0 for no):'};
dlgtitle = 'Watch BaBa';
dims = [1 80];
answer=inputdlg(prompt,dlgtitle,dims);
ID = char(answer(1));
Gaming_exp = char(answer(2));
try
%% Prepration
    % Check if Psychtoolbox is properly installed:
    AssertOpenGL;
    % get the video list and variable to store data
    video_N =  15; % the number of videos to be watched
    [videoList_coarse,videoList_fine,order] = generate_order(video_N); % generate the video list
    [practiceList_coarse,practiceList_fine] = practiceList(3); % generate the prectice List
    splitPoint_1 = zeros(video_N,1000);
    splitPoint_2 = zeros(video_N,1000);
    creativity = zeros(1,video_N);
    video_time = zeros(1,video_N);
    % Initialize with unified keynames and normalized colorspace:
    KbName('UnifyKeyNames')
    esc=KbName('escape');
    space=KbName('space');
    key_B=KbName('b');
    Return=KbName('return');
    one=KbName('1!');
    two=KbName('2@');
    three=KbName('3#');
    four=KbName('4$');
    five=KbName('5%');
    six=KbName('6^');
    seven=KbName('7&');
    eight=KbName('8*');
    nine=KbName('9(');
    Screen('Preference', 'SkipSyncTests', 1);
    PsychDefaultSetup(2);
    HideCursor;
    InitializeMatlabOpenGL;
    InitializePsychSound(1);
%% Open window and show guidence
    % open the window
    [window,rect]=Screen('OpenWindow',0,[0 0 0]); 
    cx=rect(3)/2;
    cy=rect(4)/2;
    flipInterval = Screen('GetFlipInterval',window);
    slack=flipInterval/2;
    % prepare for the sound
    [wavdata, wavrate] = audioread('sound.wav');
    wavdata = wavdata';
    [wavdata_2, wavrate_2] = audioread('sound_2.wav');
    wavdata_2 = wavdata_2';
    pahandle = PsychPortAudio('Open', [], [], 0, wavrate, 2);
    % prepare for guidence
    for i=1:5
        guidance = imread(['guideline_' num2str(i) '.png']);
        guidanceIndex = Screen('MakeTexture',window,guidance);
        % get the size of image & texture
        [imgHeight, imgWidth, ~] = size(guidance);
        [texHeight, texWidth] = Screen('WindowSize', guidanceIndex);
        % scaling ration
        scale = 0.3;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence 
        Screen('DrawTexture',window,guidanceIndex,[], dstRect);
        % time to flip
        Screen('Flip',window);
        if(i==3||i==4)
            space_flag=0;
            while 1
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    if space_flag == 0
                        if i==3
                            PsychPortAudio('FillBuffer', pahandle, wavdata);
                            PsychPortAudio('Start', pahandle); 
                            space_flag=1;
                        elseif i==4
                            PsychPortAudio('FillBuffer', pahandle, wavdata_2);
                            PsychPortAudio('Start', pahandle); 
                            space_flag=1;
                        end
                    end
                elseif space_flag==1
                    break;
                end
            end
        end
        % next guideline with mouse clicked
        while 1
            [x,y,buttons]=GetMouse;
            if buttons(1)
                clear buttons
                break;
            end
        end
        while 1
            [x,y,buttons]=GetMouse;
            if buttons(1)==0
                clear buttons
                break;
            end
        end
    end
    % show crosshair to start
    Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);         
    Screen('DrawLine',window,[255 255 255],cx,cy-30,cx ,cy+30,4);
    Screen('Flip',window);
    WaitSecs(1);
    
%% practice
    for i = 1:3
        tag=0;
        % Open video
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,practiceList_coarse(:,:,i));
        % end point
        te=time;
        % set the start point
        Screen('SetMovieTimeIndex',mwindow,0);
        screenrect=[0,0,w,h];
        % scaling ration
        scale = 1.5;
        % get the size & location of the image
        scrRect = screenrect .* scale;
        scrRect = CenterRectOnPoint(scrRect, cx, cy);
        PsychPortAudio('FillBuffer', pahandle, wavdata);
        Screen('PlayMovie',mwindow,1,0,0);
        tex=1;
        while tex
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('FillRect',window,[18,18,18],[0,0,cx*2,cy*2]);
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            vbl=Screen('Flip',window);
            
            while GetSecs<vbl+1/fps
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    PsychPortAudio('Start', pahandle); 
                    Screen('PlayMovie',mwindow,0);
                    while 1
                        [numisdown,~,numcode]=KbCheck;
                        if(numisdown && (numcode(one)||numcode(two)||numcode(three)||numcode(four)||numcode(five)||numcode(six)||numcode(seven)||numcode(eight)||numcode(nine)))
                            PsychPortAudio('Start', pahandle); 
                            clear numisdown numcode;
                            break;
                        end
                    end
                    Screen('PlayMovie',mwindow,1);
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            if(tag==1)
                break;
            end
        end
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        Screen('PlayMovie',mwindow,0);
        Screen('CloseMovie',mwindow);
        
        
        % Replay the video
        tag=0;
        press_tag=0;
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,practiceList_fine(:,:,i));
        Screen('SetMovieTimeIndex',mwindow,0 );
        screenrect = [0,0,w,h];
        % scaling ration
        scale = 1.5;
        % get the size & location of the image
        scrRect = screenrect .* scale;
        scrRect = CenterRectOnPoint(scrRect, cx, cy);
        Screen('PlayMovie',mwindow,1,0,0);
        rest_1 = imread('rest_1.png');
        rest_1Index = Screen('MakeTexture',window,rest_1);
        % get the size of image & texture
        [imgHeight, imgWidth, ~] = size(rest_1);
        [texHeight, texWidth] = Screen('WindowSize', rest_1Index);
        % scaling ration
        scale = 0.2;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence
        Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
        Screen('DrawTexture',window,rest_1Index,[], dstRect);
        % time to flip
        Screen('Flip',window);
        while 1
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                break;
            end
        end
        clear keyisdown keycode;
        % show crosshair to start
        Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);         
        Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
        Screen('Flip',window);
        WaitSecs(1);
        
        PsychPortAudio('FillBuffer', pahandle, wavdata_2);
        t1=GetSecs;
        while(GetSecs-t1<te)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('FillRect',window,[118,118,118],[0,0,cx*2,cy*2]);
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            vbl=Screen('Flip',window);
            
            while GetSecs<vbl+1/fps
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    % play sound to react
                    if press_tag == 0
                        PsychPortAudio('Start', pahandle); 
                        press_tag=1; 
                    end
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            [keyisdown,~,keycode]=KbCheck;
            press_tag=keycode(space);
            
            if(tag==1)
                break;
            end
        end
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        Screen('PlayMovie',mwindow,0);
        Screen('CloseMovie',mwindow);
        
        
        % rating
        creaRating = imread('creaRating.png');
        bad = imread('bad.png');
        good = imread('good.png');
        creaIndex = Screen('MakeTexture',window,creaRating);
        badIndex = Screen('MakeTexture',window,bad);
        goodIndex = Screen('MakeTexture',window,good);
        % set the size of the guidelines
        scale = 0.3;
        [creaHeight, creaWidth, ~] = size(creaRating);
        creaRect = [0 0 creaWidth creaHeight] .* scale;
        creaRect = CenterRectOnPoint(creaRect, cx, cy-280); 
        
        [badHeight, badWidth, ~] = size(bad);
        badRect = [0 0 badWidth badHeight] .* scale;
        badRect = CenterRectOnPoint(badRect, cx-600, cy-130); 
        
        [goodHeight, goodWidth, ~] = size(good);
        goodRect = [0 0 goodWidth goodHeight] .* scale;
        goodRect = CenterRectOnPoint(goodRect, cx+600, cy-130);
        % draw the guidence
        Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
        Screen('DrawTexture',window,creaIndex,[], creaRect);
        Screen('DrawTexture',window,goodIndex,[], goodRect);
        Screen('DrawTexture',window,badIndex,[], badRect);
        pointer_loca = cx-600+randi(1200);
        ShowCursor;
        Screen('DrawLine',window,[255 255 255],pointer_loca,cy-60,pointer_loca,cy+60,10);
        Screen('FillRect',window,[255,255,255],[cx-600,cy-40,pointer_loca,cy+40],10);
        Screen('Flip',window);
        while 1
            [return_tag,~,keycode]=KbCheck;
            if return_tag&&keycode(Return)
                break;
            end
            Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
            Screen('FrameRect',window,[255,255,255],[cx-600,cy-40,cx+600,cy+40],10);
            [mx,my,button,focus]=GetMouse;
            if button(1)
                if my>=cy-40&&my<=cy+40
                    if mx<cx-600
                        pointer_loca=cx-600;
                    elseif mx>cx+600
                        pointer_loca=cx+600;
                    else
                        pointer_loca=mx;
                    end
                end
            end
            Screen('DrawLine',window,[255 255 255],pointer_loca,cy-60,pointer_loca,cy+60,10);
            Screen('FillRect',window,[255,255,255],[cx-600,cy-40,pointer_loca,cy+40],10);
            Screen('DrawTexture',window,creaIndex,[], creaRect);
            Screen('DrawTexture',window,goodIndex,[], goodRect);  
            Screen('DrawTexture',window,badIndex,[], badRect);
            Screen('Flip',window);
            
            
        end
        HideCursor;
        
        
        if i<4
            rest_2 = imread('rest_2.png');
            rest_2Index = Screen('MakeTexture',window,rest_2);
            % get the size of image & texture
            [imgHeight, imgWidth, ~] = size(rest_2);
            [texHeight, texWidth] = Screen('WindowSize', rest_2Index);
            % scaling ration
            scale = 0.2;
            % get the size & location of the image
            dstRect = [0 0 imgWidth imgHeight] .* scale;
            dstRect = CenterRectOnPoint(dstRect, cx, cy);
            % draw the guidence
            Screen('DrawTexture',window,rest_2Index,[], dstRect);
            % time to flip
            Screen('Flip',window);
            
            while 1
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    break;
                end
            end
            
            % show crosshair to start
            Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);
            Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
            Screen('Flip',window);
            WaitSecs(1);
        
        end
    end
%% between practice & formal exp    
    intro= imread('intro.png');
    introIndex = Screen('MakeTexture',window,intro);
    % get the size of image & texture
    [imgHeight, imgWidth, ~] = size(intro);
    [texHeight, texWidth] = Screen('WindowSize', introIndex);
    % scaling ration
    scale = 0.3;
    % get the size & location of the image
    dstRect = [0 0 imgWidth imgHeight] .* scale;
    dstRect = CenterRectOnPoint(dstRect, cx, cy);
    % draw the guidence
    Screen('DrawTexture',window,introIndex,[], dstRect);
    % time to flip
    Screen('Flip',window);
    % next guideline with space pressed
    while 1
        [keyisdown,~,keycode]=KbCheck;
        if(keyisdown && keycode(space))
            break;
        end
    end
    % show crosshair to start
    Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);
    Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
    Screen('Flip',window);
    WaitSecs(1);
%% play videos
    for i = 1: video_N
        % set the start of points
        point_i=1;
        missing_i=1;
        % index for abort
        tag=0;
        % start point
        ts=0;
        % Open video
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,videoList_coarse(:,:,i));
        video_time(i)=time;
        % end point
        te=time;
        % set the start point
        Screen('SetMovieTimeIndex',mwindow,ts);
        screenrect=[0,0,w,h];
        % scaling ration
        scale = 1.5;
        % get the size & location of the image
        scrRect = screenrect .* scale;
        scrRect = CenterRectOnPoint(scrRect, cx, cy);
        Screen('PlayMovie',mwindow,1,0,0);
        tex=1;
        while tex
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('FillRect',window,[18,18,18],[0,0,cx*2,cy*2]);
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            vbl=Screen('Flip',window);
            
            while GetSecs<vbl+1/fps
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    pausetime=Screen('GetMovieTimeIndex', mwindow);
                    PsychPortAudio('FillBuffer', pahandle, wavdata);
                    PsychPortAudio('Start', pahandle);
                    Screen('PlayMovie',mwindow,0);
                    while 1
                        [numisdown,~,numcode]=KbCheck;
                        if(numisdown&& (numcode(one)||numcode(two)||numcode(three)||numcode(four)||numcode(five)||numcode(six)||numcode(seven)||numcode(eight)||numcode(nine)))
                            PsychPortAudio('Start', pahandle); 4
                            if numcode(one)
                                splitPoint_1(i,point_i)=pausetime-1;
                            elseif numcode(two)
                                splitPoint_1(i,point_i)=pausetime-2;
                            elseif numcode(three)
                                splitPoint_1(i,point_i)=pausetime-3;
                            elseif numcode(four)
                                splitPoint_1(i,point_i)=pausetime-4;
                            elseif numcode(five)
                                splitPoint_1(i,point_i)=pausetime-5;
                            elseif numcode(six)
                                splitPoint_1(i,point_i)=pausetime-6;
                            elseif numcode(seven)
                                splitPoint_1(i,point_i)=pausetime-7;
                            elseif numcode(eight)
                                splitPoint_1(i,point_i)=pausetime-8;
                            elseif numcode(nine)
                                splitPoint_1(i,point_i)=pausetime-9;
                            end
                            point_i=point_i+1;
                            clear numisdown numcode;
                            break;
                        end
                    end
                    Screen('PlayMovie',mwindow,1);
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            
            if(tag==1)
                break;
            end
        end
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        if(point_i==1||splitPoint_1(i,point_i-1)<te-0.5)
            splitPoint_1(i,point_i)=te;
        end
        Screen('PlayMovie',mwindow,0);
        Screen('CloseMovie',mwindow);
        % Replay the video
        tag=0;
        press_tag=0;
        [mwindow,time,fps,w,h,zhenshu]=Screen('OpenMovie',window,videoList_fine(:,:,i));
        Screen('SetMovieTimeIndex',mwindow,ts);
        screenrect = [0,0,w,h];
        % scaling ration
        scale = 1.5;
        % get the size & location of the image
        scrRect = screenrect .* scale;
        scrRect = CenterRectOnPoint(scrRect, cx, cy);
        Screen('PlayMovie',mwindow,1,0,0);
        point_i=1;
        rest_1 = imread('rest_1.png');
        rest_1Index = Screen('MakeTexture',window,rest_1);
        % get the size of image & texture
        [imgHeight, imgWidth, ~] = size(rest_1);
        [texHeight, texWidth] = Screen('WindowSize', rest_1Index);
        % scaling ration
        scale = 0.3;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence
        Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
        Screen('DrawTexture',window,rest_1Index,[], dstRect);
        % time to flip
        Screen('Flip',window);
        while 1
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                break;
            end
        end
        % show crosshair to start
        Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);
        Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
        Screen('Flip',window);
        WaitSecs(1);
        PsychPortAudio('FillBuffer', pahandle, wavdata_2);
        t1=GetSecs;
        while(GetSecs-t1<te)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('FillRect',window,[118,118,118],[0,0,cx*2,cy*2]);
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            
            vbl=Screen('Flip',window);
            
            while GetSecs<vbl+1/fps
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    % play sound to react
                    if press_tag == 0
                        splitPoint_2(i,point_i)=Screen('GetMovieTimeIndex', mwindow);
                        point_i=point_i+1;
                        PsychPortAudio('Start', pahandle);
                        press_tag=1;
                        break;
                    end
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            [keyisdown,~,keycode]=KbCheck;
            press_tag=keycode(space);
            
            if(tag==1)
                break;
            end
        end
        
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        if(point_i==1||splitPoint_2(i,point_i-1)<te-0.5)
            splitPoint_2(i,point_i)=te;
        end
        Screen('PlayMovie',mwindow,0);
        Screen('CloseMovie',mwindow);
        
        % rating
        creaRating = imread('creaRating.png');
        bad = imread('bad.png');
        good = imread('good.png');
        creaIndex = Screen('MakeTexture',window,creaRating);
        badIndex = Screen('MakeTexture',window,bad);
        goodIndex = Screen('MakeTexture',window,good);
        % set the size of the guidelines
        scale = 0.3;
        [creaHeight, creaWidth, ~] = size(creaRating);
        creaRect = [0 0 creaWidth creaHeight] .* scale;
        creaRect = CenterRectOnPoint(creaRect, cx, cy-280); 
        
        [badHeight, badWidth, ~] = size(bad);
        badRect = [0 0 badWidth badHeight] .* scale;
        badRect = CenterRectOnPoint(badRect, cx-600, cy-130); 
        
        [goodHeight, goodWidth, ~] = size(good);
        goodRect = [0 0 goodWidth goodHeight] .* scale;
        goodRect = CenterRectOnPoint(goodRect, cx+600, cy-130);
        % draw the guidence
        Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
        Screen('DrawTexture',window,creaIndex,[], creaRect);
        Screen('DrawTexture',window,goodIndex,[], goodRect);
        Screen('DrawTexture',window,badIndex,[], badRect);
        pointer_loca = cx-600+randi(1200);
        ShowCursor;
        Screen('DrawLine',window,[255 255 255],pointer_loca,cy-60,pointer_loca,cy+60,10);
        Screen('FillRect',window,[255,255,255],[cx-600,cy-40,pointer_loca,cy+40],10);
        Screen('Flip',window);
        while 1
            [return_tag,~,keycode]=KbCheck;
            if return_tag&&keycode(Return)
                creativity(i)=(pointer_loca-cx+600)/12;
                break;
            end
            Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
            Screen('FrameRect',window,[255,255,255],[cx-600,cy-40,cx+600,cy+40],10);
            [mx,my,button,focus]=GetMouse;
            if button(1)
                if my>=cy-40&&my<=cy+40
                    if mx<cx-600
                        pointer_loca=cx-600;
                    elseif mx>cx+600
                        pointer_loca=cx+600;
                    else
                        pointer_loca=mx;
                    end
                end
            end
            Screen('DrawLine',window,[255 255 255],pointer_loca,cy-60,pointer_loca,cy+60,10);
            Screen('FillRect',window,[255,255,255],[cx-600,cy-40,pointer_loca,cy+40],10);
            Screen('DrawTexture',window,creaIndex,[], creaRect);
            Screen('DrawTexture',window,goodIndex,[], goodRect);  
            Screen('DrawTexture',window,badIndex,[], badRect);
            Screen('Flip',window);
        end
        HideCursor;
        
        if i<video_N
            rest_2 = imread('rest_2.png');
            rest_2Index = Screen('MakeTexture',window,rest_2);
            % get the size of image & texture
            [imgHeight, imgWidth, ~] = size(rest_2);
            Screen('FillRect',window,0,[0,0,cx*2,cy*2]);
            [texHeight, texWidth] = Screen('WindowSize', rest_2Index);
            % scaling ration
            scale = 0.3;
            % get the size & location of the image
            dstRect = [0 0 imgWidth imgHeight] .* scale;
            dstRect = CenterRectOnPoint(dstRect, cx, cy);
            % draw the guidence
            Screen('DrawTexture',window,rest_2Index,[], dstRect);
            % time to flip
            Screen('Flip',window);
            while 1
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    break;
                end
            end
            % show crosshair to start
            Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);
            Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
            Screen('Flip',window);
            WaitSecs(1);
        end
    end
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    %% clean and save the data
    splitPoint.order = order;
    splitPoint.time = video_time;
    splitPoint.the_coarse = splitPoint_1;
    splitPoint.the_fine = splitPoint_2;
    splitPoint.creaPoint = creativity;
    save([cd '\SAVE\' ID '_' Gaming_exp '_SplitPoint.mat'],'splitPoint');
    sca;
catch
    sca;
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

