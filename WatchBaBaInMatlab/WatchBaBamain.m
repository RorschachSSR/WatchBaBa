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
    video_N = 12; % the number of videos to be watched
    videoList = generate_order(video_N); % generate the video list
    practiceList = practiceList(3); % generate the prectice List
    splitPoint_1 = zeros(video_N,1000);
    splitPoint_2 = zeros(video_N,1000);
    video_time = zeros(1,N);
    % Initialize with unified keynames and normalized colorspace:
    KbName('UnifyKeyNames')
    esc=KbName('escape');
    space=KbName('space');
    Screen('Preference', 'SkipSyncTests', 1);
    PsychDefaultSetup(2);
    HideCursor;
    InitializeMatlabOpenGL;
%% Open window and show guidence
    % open the window
    [window,rect]=Screen('OpenWindow',0,[0 0 0]); 
    cx=rect(3)/2;
    cy=rect(4)/2;
    % prepare for play video
    flipInterval=Screen('GetFlipInterval',window);
    slack=flipInterval/2;
    
    % prepare for guidence
    for i=1:3
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
        % next guideline with space pressed
        while 1
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                break;
            end
        end
    end
    
%% practice
    for i = 1:4
        tag=0;
        % Open video
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,practiceList(:,:,i));
        % end point
        te=time;
        % set the start point
        Screen('SetMovieTimeIndex',mwindow,0);
        screenrect=[0,0,w,h];
        % scaling ration
        scale = 1;
        % get the size & location of the image
        scrRect = screenrect .* scale;
        scrRect = CenterRectOnPoint(scrRect, cx, cy);
        Screen('PlayMovie',mwindow,1,0,0);
        t1=GetSecs;
        n=1;
        while(GetSecs-t1<te)
            tic
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            T(n)=toc;
            n=n+1;
            if(tex<=0)
                break;
            end
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                % show crosshair to react
                Screen('DrawLine',window,[255 255 255],cx-30,30,cx+30,30,4);
                Screen('DrawLine',window,[255 255 255],cx,0,cx,60,4);
            elseif(keyisdown && keycode(esc))
                tag=1;
                break;
            end
            Screen('Flip',window);
            
        end
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        Screen('PlayMovie',mwindow,0);
        Screen('CloseMovie',mwindow);
        % Replay the video
        [mwindow,time,fps,w,h]=Screen('OpenMovie',window,practiceList(:,:,i));
        Screen('SetMovieTimeIndex',mwindow,0 );
        screenrect = [0,0,w,h];
        % scaling ration
        scale = 1;
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
        scale = 0.3;
        % get the size & location of the image
        dstRect = [0 0 imgWidth imgHeight] .* scale;
        dstRect = CenterRectOnPoint(dstRect, cx, cy);
        % draw the guidence
        Screen('DrawTexture',window,rest_1Index,[], dstRect);
        % time to flip
        Screen('Flip',window);
        WaitSecs(3);
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
            Screen('Flip',window);
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                % show crosshair to react
                Screen('DrawLine',window,[255 255 255],cx-30,30,cx+30,30,4);
                Screen('DrawLine',window,[255 255 255],cx,0,cx,60,4);
            elseif(keyisdown && keycode(esc))
                tag=1;
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
            scale = 0.3;
            % get the size & location of the image
            dstRect = [0 0 imgWidth imgHeight] .* scale;
            dstRect = CenterRectOnPoint(dstRect, cx, cy);
            % draw the guidence
            Screen('DrawTexture',window,rest_2Index,[], dstRect);
            % time to flip
            Screen('Flip',window);
            WaitSecs(5);
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
        % index for abort
        tag=0;
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
        scale = 1;
        % get the size & location of the image
        scrRect = screenrect .* scale;
        scrRect = CenterRectOnPoint(scrRect, cx, cy);
        Screen('PlayMovie',mwindow,1,0,0);
        t1=GetSecs;
        while(GetSecs-t1<te-ts)
            tex=Screen('GetMovieImage',window,mwindow,[],[],2);
            if(tex<=0)
                break;
            end
            Screen('DrawTexture',window,tex,[],scrRect);
            Screen('Close',tex);
            Screen('Flip',window);
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                splitPoint_1(i,point_i)=Screen('GetMovieTimeIndex', mwindow);
                point_i=point_i+1;
                % show crosshair to react
                Screen('DrawLine',window,[255 255 255],cx-30,30,cx+30,30,4);
                Screen('DrawLine',window,[255 255 255],cx,0,cx,60,4);
            elseif(keyisdown && keycode(esc))
                tag=1;
                break;
            end
        end
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        if(splitPoint_1(i,point_i-1)<te-0.5)
            splitPoint_1(i,point_i)=te;
        end
        Screen('PlayMovie',mwindow,0);
        Screen('CloseMovie',mwindow);
        % Replay the video
        [mwindow,time,fps,w,h,zhenshu]=Screen('OpenMovie',window,videoList(:,:,i));
        Screen('SetMovieTimeIndex',mwindow,ts);
        screenrect = [0,0,w,h];
        % scaling ration
        scale = 1;
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
        Screen('DrawTexture',window,rest_1Index,[], dstRect);
        % time to flip
        Screen('Flip',window);
        WaitSecs(3);
        % show crosshair to start
        Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);
        Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
        Screen('Flip',window);
        WaitSecs(1);
        t1=GetSecs;
        while(GetSecs-t1<te-ts)
             
            [keyisdown,~,keycode]=KbCheck;
            if(keyisdown && keycode(space))
                splitPoint_2(i,point_i)=Screen('GetMovieTimeIndex', mwindow);
                point_i=point_i+1;
                % show crosshair to react
                Screen('DrawLine',window,[255 255 255],cx-30,30,cx+30,30,4);
                Screen('DrawLine',window,[255 255 255],cx,0,cx,60,4);
            elseif(keyisdown && keycode(esc))
                tag=1;
                break;
            end
        end
        if(tag==1)
            Screen('PlayMovie',mwindow,0);
            Screen ('CloseMovie',mwindow);
            break;
        end
        if(splitPoint_2(i,point_i-1)<te-0.5)
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
            scale = 0.3;
            % get the size & location of the image
            dstRect = [0 0 imgWidth imgHeight] .* scale;
            dstRect = CenterRectOnPoint(dstRect, cx, cy);
            % draw the guidence
            Screen('DrawTexture',window,rest_2Index,[], dstRect);
            % time to flip
            Screen('Flip',window);
            WaitSecs(5);
            % show crosshair to start
            Screen('DrawLine',window,[255 255 255],cx-30,cy,cx+30,cy,4);
            Screen('DrawLine',window,[255 255 255],cx,cy-30,cx,cy+30,4);
            Screen('Flip',window);
            WaitSecs(1);
        end
    end
    %% clean and save the data
    splitPoint.video = videoList;
    splitPoint.time = video_time;
    splitPoint.the_coarse = splitPoint_1;
    splitPoint.the_fine = splitPoint_2;
    save([cd '\SAVE\' ID '_' Gaming_exp '_SplitPoint.mat'],'splitPoint');
    sca;
catch
    sca;
    Screen('CloseAll');
    ShowCursor;
    psychrethrow(psychlasterror);
end

