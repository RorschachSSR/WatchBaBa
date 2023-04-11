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
    videoList = generate_order(video_N); % generate the video list
    practiceList = practiceList(3); % generate the prectice List
    splitPoint_1 = zeros(video_N,1000);
    splitPoint_2 = zeros(video_N,1000);
    missingPoint = zeros(video_N,1000);
    video_time = zeros(1,video_N);
    % Initialize with unified keynames and normalized colorspace:
    KbName('UnifyKeyNames')
    esc=KbName('escape');
    space=KbName('space');
    key_B=KbName('b');
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
    pahandle = PsychPortAudio('Open', [], [], 0, wavrate, 2);
    PsychPortAudio('FillBuffer', pahandle, wavdata);
    % prepare for guidence
    for i=1:3
        guidance = imread(['guideline_' num2str(i) '.png']);
        guidanceIndex = Screen('MakeTexture',window,guidance);
        % get the size of image & texture
        [imgHeight, imgWidth, ~] = size(guidance);
        [texHeight, texWidth] = Screen('WindowSize', guidanceIndex);
        % scaling ration
        scale = 0.4;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence 
        Screen('DrawTexture',window,guidanceIndex,[], dstRect);
        % time to flip
        Screen('Flip',window);
        if(i==1)
            space_flag=0;
            while 1
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    if space_flag == 0
                        PsychPortAudio('Start', pahandle);
                        space_flag=1;
                    end
                elseif space_flag==1
                    break;
                end
            end
        end
        % next guideline with mouse clicked
        while 1
            [x,y,buttons]=GetMouse;
            if sum(buttons)>0
                clear buttons
                break;
            end
        end
    end
    % show crosshair to start
    Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);         
    Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
    Screen('Flip',window);
    WaitSecs(1);
    
%% practice
    for i = 1:3
        tag=0;
        press_tag=0;
        % Open video
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,practiceList(:,:,i));
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
        Screen('PlayMovie',mwindow,1,0,0);
        t1=GetSecs;
        while(GetSecs-t1<te)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
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
                        break;
                    end
                elseif(keyisdown && keycode(key_B))
                    if press_tag == 0
                        PsychPortAudio('Start', pahandle);
                        press_tag=1;
                        break;
                    end
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            [press_tag,~,keycode]=KbCheck;
            
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
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,practiceList(:,:,i));
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
        scale = 0.4;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence
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
        t1=GetSecs;
        while(GetSecs-t1<te)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
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
                        break;
                    end
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            [press_tag,~,keycode]=KbCheck;
            
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
        
        if i<4
            rest_2 = imread('rest_2.png');
            rest_2Index = Screen('MakeTexture',window,rest_2);
            % get the size of image & texture
            [imgHeight, imgWidth, ~] = size(rest_2);
            [texHeight, texWidth] = Screen('WindowSize', rest_2Index);
            % scaling ration
            scale = 0.4;
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
    scale = 0.5;
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
        press_tag=0;
        % start point
        ts=0;
        % Open video
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,videoList(:,:,i));
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
        t1=GetSecs;
        while(GetSecs-t1<te)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            
            vbl=Screen('Flip',window);
            
            while GetSecs<vbl+1/fps
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    % play sound to react
                    if press_tag == 0
                        splitPoint_1(i,point_i)=Screen('GetMovieTimeIndex', mwindow);
                        point_i=point_i+1;
                        PsychPortAudio('Start', pahandle);
                        press_tag=1;
                        break;
                    end
                elseif(keyisdown && keycode(key_B))
                    if press_tag == 0
                        missingPoint(i,missing_i)=Screen('GetMovieTimeIndex', mwindow);
                        missing_i=missing_i+1;
                        PsychPortAudio('Start', pahandle);
                        press_tag=1;
                        break;
                    end
                elseif(keyisdown && keycode(esc))
                    tag=1;
                    break;
                end
            end
            
            [press_tag,~,keycode]=KbCheck;
            
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
        [mwindow,time,fps,w,h,zhenshu]=Screen('OpenMovie',window,videoList(:,:,i));
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
        scale = 0.4;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence
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
        t1=GetSecs;
        while(GetSecs-t1<te)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            
            vbl=Screen('Flip',window);
            
            while GetSecs<vbl+1/fps
                [keyisdown,~,keycode]=KbCheck;
                if(keyisdown && keycode(space))
                    % play sound to react
                    if press_tag == 0
                        splitPoint_1(i,point_i)=Screen('GetMovieTimeIndex', mwindow);
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
            
            [press_tag,~,keycode]=KbCheck;
            
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
        
        if i<video_N
            rest_2 = imread('rest_2.png');
            rest_2Index = Screen('MakeTexture',window,rest_2);
            % get the size of image & texture
            [imgHeight, imgWidth, ~] = size(rest_2);
            [texHeight, texWidth] = Screen('WindowSize', rest_2Index);
            % scaling ration
            scale = 0.4;
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
    splitPoint.video = videoList;
    splitPoint.time = video_time;
    splitPoint.the_coarse = splitPoint_1;
    splitPoint.the_fine = splitPoint_2;
    splitPoint.missingPoint=missingPoint;
    save([cd '\SAVE\' ID '_' Gaming_exp '_SplitPoint.mat'],'splitPoint');
    sca;
catch
    sca;
    Screen('CloseAll');
    ShowCursor;
    psychrethrow(psychlasterror);
end

