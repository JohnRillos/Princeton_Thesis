% Test Trial
function testtrial(subjectID, N_runs)

%% Set up screen

% Initialize pseudorandom stream
reset(RandStream.getGlobalStream,sum(100*clock))

% Background color
back_color = [0; 0; 0]; 

% Screen('Preference', 'SkipSyncTests', 1)
%%%%% Screen('Preference', 'ConserveVRAM', 4096); % fixes small timing issue

% Make sure Psychtoolbox is properly installed and set it up for use at
% feature level 2: Normalized 0-1 color range and unified key mapping.
PsychDefaultSetup(2);

% Select the display screen on which to show our window:
screenid = max(Screen('Screens'));

% Open a window on display screen 'screenid'. We choose a 50% gray
% background by specifying a luminance level of 0.5:
[win, rect_screen] = PsychImaging('Openwindow', screenid, back_color);
HideCursor;


%% CALCULATE MONITOR REFRESH RATE

fstart = GetSecs;
for f = 1:50 % 50 frames
    Screen('FillRect', win, back_color, [0;0;1;1] );    
    Screen('Flip', win);
end
fps = round(50/(GetSecs - fstart)) % frames per second

%% CONSTANTS

dev_text = false;

[center_h, center_v] = RectCenter(rect_screen);
[p_width, p_height] = RectSize(rect_screen); % screen size in pixels

c_dist = 30.5; % 36.5; % 30.5; % distance from screen in centimeters
c_width = 34.29; % 41;
c_height = 20.59; % 30; % screen size in centimeters
d_width = 180*c_width/(pi*c_dist);
d_height = 180*c_height/(pi*c_dist); % screen size in visual degrees

cm_per_px = c_width/p_width;
k = pi*c_dist*p_width/(180*c_width); % degrees to pixels constant


dist_h = 8.3874*k; % 250; % cue's distance from horizontal center
cue_rad = 0.6710*k; % 20; 
fix_rad = 3; % radius of fixation point

targ_dist = 7.7164*k; % 230; % target's distance from vertical center

cue_time = 0.08; % time cue is on screen (seconds)
cue_frames = round(cue_time*fps) % 6;
speed = (1.5097*k)*(6/cue_frames) % 45; % pixels per frame (cue movement)

time_per_target = 0.65; % seconds target is displayed
targ1_rad = 1.3420*k; % 40; % radius of outer circle (white)
targ2_rad = 1.0065*k; % 30; % radius of inner circle (black)
thickness = 0.0503*k; % 1.5; % how lopsided the target is

min_ITI = 1.5;
max_ITI = 3;

right = 1;
left = -1;

neglect = 0; % use neglect = left for left-masking

up = -1;
down = 1;

white =  [100,100,100];
yellow = [100,100,  0];
black =  [  0,  0,  0];

if nargin == 0;
    subjectID = 'anon';
    N_runs = 1;
end

if nargin == 1;
    N_runs = 9;
end

% vertical center of target
targ_pos_up = center_v + up*targ_dist;
targ_pos_dn = center_v + down*targ_dist;

targ1_up_top = [center_h - targ1_rad, targ_pos_up - targ1_rad - thickness, ...
                center_h + targ1_rad, targ_pos_up + targ1_rad - thickness];
        
targ1_up_bot = [center_h - targ1_rad, targ_pos_up - targ1_rad + thickness, ...
                center_h + targ1_rad, targ_pos_up + targ1_rad + thickness];
        
targ2_up = [center_h - targ2_rad, targ_pos_up - targ2_rad, ... 
            center_h + targ2_rad, targ_pos_up + targ2_rad];
        
targ1_dn_top = [center_h - targ1_rad, targ_pos_dn - targ1_rad - thickness, ...
                center_h + targ1_rad, targ_pos_dn + targ1_rad - thickness];
        
targ1_dn_bot = [center_h - targ1_rad, targ_pos_dn - targ1_rad + thickness, ...
                center_h + targ1_rad, targ_pos_dn + targ1_rad + thickness];
        
targ2_dn = [center_h - targ2_rad, targ_pos_dn - targ2_rad, ... 
            center_h + targ2_rad, targ_pos_dn + targ2_rad];
        
        
%% Define number of conditions for each variable

N_aware_conditions = 3; 
awareness = 1;          % 1. aware/unaware cue
unaware = 1;                % 1 = unaware condition
aware = 2;                  % 2 = aware condition
no_cue = 3;                 % 3 = no cue

N_cue_move = 2; 
cue_move = 2;           % 2. cue movement
cue_up = 1;                 % 1 = cue up
cue_down = 2;               % 2 = cue down

N_target_locations = 2; 
target_location = 3;    % 3. target location
target_up = 1;              % 1 = target up
target_down = 2;            % 2 = target down

N_target_types = 2;
target_type = 4;        % 4. target orientation
thick_top = 1;              % 1 = thick top
thick_bottom = 2;           % 2 = thick bottom


% Load these values into a struct for output
condition_key.awareness = awareness;
condition_key.unaware = unaware;
condition_key.aware = aware;

condition_key.cue_move = cue_move;
condition_key.cue_up = cue_up;
condition_key.cue_down = cue_down;
condition_key.no_cue = no_cue;

condition_key.target_location = target_location;
condition_key.target_up = target_up;
condition_key.target_down = target_down;

condition_key.target_type = target_type;
condition_key.thick_top = thick_top;
condition_key.thick_bottom = thick_bottom;


%% Make matrix perfectly counterbalanced for all conditions of all variables

N_variables = 4;
N_permutations = N_aware_conditions * N_cue_move * N_target_locations ...
    * N_target_types;
counterbalanced_matrix = NaN(N_permutations,N_variables);

permutation_counter = 1;
for aware_condition = 1:N_aware_conditions
    for cue_location_condition = 1:N_cue_move
        for target_location_condition = 1:N_target_locations
            for target_type_condition = 1:N_target_types
        
                counterbalanced_matrix(permutation_counter,:) = [...
                    aware_condition, cue_location_condition, ...
                    target_location_condition, target_type_condition];
        
                permutation_counter = permutation_counter + 1;
            end
        end
    end
end

N_trials = size(counterbalanced_matrix,1);

stimulus_matrix = zeros(N_trials,N_variables,N_runs);

for run = 1:N_runs
    stimulus_matrix(:,:,run) = counterbalanced_matrix(randperm(N_trials),:);
end


%% Initialize data

% 1 - up/down response
% 2 - cue onset
% 3 - cue offset
% 4 - target onset
% 5 - target offset
% 6 - response time
% 7 - ITI
data = zeros(N_trials, 7, N_runs);

%% Set up file for output

sFile_name = sprintf('john_thesis/data/task1_%s_%s', subjectID, date);
nFile_version = 1;

% Keep incrementing the index as long as it exists.
foo = dir([sFile_name '.mat']);

while ~isempty(foo)
    nFile_version = nFile_version + 1;
    sFile_name = sprintf('john_thesis/data/task1_%s_%s_v%d', subjectID, date, nFile_version);
    foo = dir([sFile_name '.mat']);
end


%% Set up keys

% Make KbName use shared name mapping of keys between PC and Mac
KbName('UnifyKeyNames');

% Designate key codes
UpKey     = KbName('i');               
DownKey   = KbName('k');    


%% COUNTDOWN

Screen('TextSize', win, 36);
Screen('TextColor', win, [1, 1, 1]);
DrawFormattedText(win, '3', 'center', 'center');
Screen('Flip', win);
WaitSecs(0.5);
DrawFormattedText(win, '2', 'center', 'center');
Screen('Flip', win);
WaitSecs(0.5);
DrawFormattedText(win, '1', 'center', 'center');
Screen('Flip', win);
WaitSecs(0.5);


% Instructions?
ins_y_n = sprintf('Instructions?\nI = Yes, K = No');
DrawFormattedText(win, ins_y_n, 'center', 'center');
Screen('Flip', win);

bWaiting = true;       
instruct = false;

while bWaiting,
    % Check for code
    [key_press, ~, key_code] = KbCheck(-1);
    if key_press; 
        if key_code(UpKey);
            instruct = true;
            bWaiting = false;
        elseif key_code(DownKey);
            bWaiting = false;
        end
    end
end

% short gap so next prompt isn't automatically skipped
WaitSecs(0.1);

%% INSTRUCTIONS

if instruct
    
    % cell array
    instructions = cell(5,1);
    x = 7;
    
    instructions{1} = sprintf('At the start of each trial,\n a small white circle will appear\nin the center of the screen.');
    instructions{2} = sprintf('');
    instructions{3} = sprintf('Focus on that point.');
    instructions{4} = sprintf('Next, a small square may appear\non either side of the screen.');
    instructions{5} = sprintf('');
    instructions{6} = sprintf('It will quickly move up or down,\nor it may not appear at all.');
    instructions{7} = sprintf('You do not have to pay attention to the moving square.\nNext comes the important part...');
    instructions{x+1} = sprintf('A lopsided ring will appear, briefly.');
    instructions{x+2} = sprintf('It can appear above the center of the screen...');
    instructions{x+3} = sprintf('... or below the center of the screen.');
    instructions{x+4} = sprintf('Press I if the top\nof the ring is thicker.');
    instructions{x+5} = sprintf('Press K if the bottom\nof the ring is thicker.');
    instructions{x+6} = sprintf('Answer as quickly as possible,\n while the ring is still on screen.');
    instructions{x+7} = sprintf('End of instructions.');
    
    for step = 1:size(instructions);
        
        if step == 2
            Screen('FillOval', win, white, ...
                [center_h - fix_rad; center_v - fix_rad; ...
                 center_h + fix_rad; center_v + fix_rad], 2*fix_rad);
        end
        
        if step == 5
            for i = 0:cue_frames-1 % frames in 1 cue
                pos_h = center_h + right*dist_h;
                pos_v = center_v + up*speed*i; % move vertically
                cue = [pos_h - cue_rad; pos_v - cue_rad; pos_h + cue_rad; pos_v + cue_rad];
                Screen('FillRect', win, white, cue )
                Screen('Flip', win)
            end
        end
        
        if step < x+7 && step > x;
            if step ~= x+3; % target above center
                if step ~= x+5; % thicker on top
                    targ1 = targ1_up_top;
                else % thicker on bottom
                    targ1 = targ1_up_bot;
                end
                targ2 = targ2_up;
            else % target below center
                targ1 = targ1_dn_top;
                targ2 = targ2_dn;
            end
            Screen('FillOval', win, white, targ1);
            Screen('FillOval', win, black, targ2);
        end
        
        if step == x+4;     % thick on top
            pointer = [targ1(3), targ1(2) - 3, targ1(3) + 2*targ1_rad, targ1(2) + 3]; 
            Screen('FillRect', win, yellow, pointer)
        elseif step == x+5; % thick on bottom
            pointer = [targ1(3), targ1(4) - 3, targ1(3) + 2*targ1_rad, targ1(4) + 3]; 
            Screen('FillRect', win, yellow, pointer)
        end
        
        DrawFormattedText(win, instructions{step}, 'center', 'center');

        Screen('Flip', win);
        
        bWaiting = true;         
        while bWaiting,
            % Check for code
            [bKey_press] = KbCheck(-1);
            bWaiting = ~(bKey_press);
        end 
        
        % short gap so next prompt isn't automatically skipped
        WaitSecs(0.3);
    end
end

%% PRACTICE RUN

pra_y_n = sprintf('Would you like to do a practice run?\nI = Yes, K = No');
DrawFormattedText(win, pra_y_n, 'center', 'center');
Screen('Flip', win);

bWaiting = true;       

while bWaiting,
    % Check for code
    [key_press, ~, key_code] = KbCheck(-1);
    if key_press;
        if key_code(UpKey);
            practice = true;
            bWaiting = false;
        elseif key_code(DownKey);
            practice = false;
            bWaiting = false;
        end
    end
end


%% Wait for any key 

WaitSecs(0.3);
DrawFormattedText(win, 'Press any key to start', 'center', 'center');
Screen('Flip', win);

bWaiting = true;         
while bWaiting,
    % Check for code
    [bKey_press] = KbCheck(-1);
    bWaiting = ~(bKey_press);
end


%% PRACTICE TRIAL

while practice;
    
    run = 1;
    p_score = 0;
    P_trials = N_trials/2;
    
    DrawFormattedText(win, '3', 'center', 'center');
    Screen('Flip', win);
    WaitSecs(0.5);
    DrawFormattedText(win, '2', 'center', 'center');
    Screen('Flip', win);
    WaitSecs(0.5);
    DrawFormattedText(win, '1', 'center', 'center');
    Screen('Flip', win);
    WaitSecs(0.5);
    
for trial = 1:P_trials;

    if stimulus_matrix(trial,1,run) == 1
        side = left;
    elseif stimulus_matrix(trial,1,run) == 2
        side = right;
    else
        side = no_cue;
    end
    
    if stimulus_matrix(trial,2,run) == 1
        direction = up;
    else
        direction = down;
    end
        
    if stimulus_matrix(trial,3,run) == 1
        targ_side = up;
    else
        targ_side = down;
    end
    
    if stimulus_matrix(trial,4,run) == 1
        thick = up;
    else
        thick = down;
    end
    
    
% RENDER FIXATION POINT

Screen('FillOval', win, white, ...
    [center_h - fix_rad; center_v - fix_rad; ...
    center_h + fix_rad; center_v + fix_rad], 2*fix_rad);

if dev_text
    RunTrial = sprintf('Run:%d Trial:%d', run, trial);
    DrawFormattedText(win, RunTrial, 'left', 'center');
end
    
Screen('Flip', win);
WaitSecs(2);


% RENDER CUE

if side == 3
    cue_color = black;
else
    if neglect == left % left-neglect
        if side == left
            cue_color = yellow;
        else
            cue_color = white;
        end
    elseif neglect == right % right-neglect
        if side == right
            cue_color = yellow;
        else
            cue_color = white;
        end
    else % no neglect
        cue_color = white;
    end
end

for i = 0:cue_frames-1 % frames in 1 cue
    pos_h = center_h + side*dist_h;
    pos_v = center_v + direction*speed*i; % move vertically

    cue = [pos_h - cue_rad; pos_v - cue_rad; pos_h + cue_rad; pos_v + cue_rad];

    Screen('FillRect', win, cue_color, cue );    
    Screen('Flip', win);
    
    if i == 0
        data(trial,2,run) = GetSecs;
    end

    if dev_text
        DrawFormattedText(win, RunTrial, 'left', 'center');
    end
    
end


%% RENDER TARGET

% targ_side = down; % where the target appears
% thick = up; % which side is thick

if targ_side == up;
    targ2 = targ2_up;
    if thick == up;
        targ1 = targ1_up_top;
    else
        targ1 = targ1_up_bot;
    end
else
    targ2 = targ2_dn;
    if thick == up;
        targ1 = targ1_dn_top;
    else
        targ1 = targ1_dn_bot;
    end
end

Screen('FillOval', win, white, targ1);
Screen('FillOval', win, black, targ2);
Screen('Flip', win);


start_target = GetSecs;

can_press = true;

while GetSecs - start_target < time_per_target;
    
    if dev_text
        DrawFormattedText(win, RunTrial, 'left', 'center');
    end
    
    [key_press,~,key_code] = KbCheck(-1);
    if key_press && can_press
        can_press = false;
        if key_code(UpKey)
            if thick == up
                p_score = p_score + 1;
            end
        elseif key_code(DownKey)
            if thick == down
                p_score = p_score + 1;
            end
        end
    end
        
end

%% Intertrial interval

ITI = (rand*(max_ITI - min_ITI)) + min_ITI;
Screen('Flip', win);

start_ITI = GetSecs;
while GetSecs - start_ITI < ITI;
    
    [key_press,~,key_code] = KbCheck(-1);
    if key_press && can_press
        can_press = false;
        if key_code(UpKey);
            if thick == up
                p_score = p_score + 1;
            end
        elseif key_code(DownKey)
            if thick == down
                p_score = p_score + 1;
            end
        end
    end
end
    
end


prac_acc = round(p_score/P_trials,2);
EndPrac = sprintf('End of practice run.\nAccuracy %d\nPress any key to continue', prac_acc);

DrawFormattedText(win, EndPrac, 'center', 'center');
Screen('Flip', win);

bWaiting = true;
while bWaiting
    [bKey_press] = KbCheck(-1);
    bWaiting = ~(bKey_press);
end

DrawFormattedText(win, 'Do another practice run?\nI = Yes, K = No', 'center', 'center');
Screen('Flip', win);


bWaiting = true;
WaitSecs(0.3);
while bWaiting,
    % Check for code
    [key_press, ~, key_code] = KbCheck(-1);
    if key_press
        if key_code(UpKey)
            practice = true;
            bWaiting = false;
        elseif key_code(DownKey)
            practice = false;
            bWaiting = false;
        end
    end
end


end

%% Pre-Task

WaitSecs(0.3);
pretask_text = sprintf('The task will have %d runs of %d trials each.', N_runs, N_trials);
DrawFormattedText(win, pretask_text, 'center', 'center');
Screen('Flip', win);

bWaiting = true;         
while bWaiting,
    % Check for code
    [bKey_press] = KbCheck(-1);
    bWaiting = ~(bKey_press);
end


WaitSecs(0.5);
DrawFormattedText(win, 'Press any key to start task', 'center', 'center');
Screen('Flip', win);

bWaiting = true;         
while bWaiting,
    % Check for code
    [bKey_press] = KbCheck(-1);
    bWaiting = ~(bKey_press);
end


%% COMMENCE TRIALS

time_start = GetSecs;

for run = 1:N_runs;
    
    DrawFormattedText(win, '3', 'center', 'center');
    Screen('Flip', win);
    WaitSecs(0.5);
    DrawFormattedText(win, '2', 'center', 'center');
    Screen('Flip', win);
    WaitSecs(0.5);
    DrawFormattedText(win, '1', 'center', 'center');
    Screen('Flip', win);
    WaitSecs(0.5);
    
for trial = 1:N_trials;

    if stimulus_matrix(trial,1,run) == 1
        side = left;
    elseif stimulus_matrix(trial,1,run) == 2
        side = right;
    else
        side = no_cue;
    end
    
    if stimulus_matrix(trial,2,run) == 1
        direction = up;
    else
        direction = down;
    end
        
    if stimulus_matrix(trial,3,run) == 1
        targ_side = up;
    else
        targ_side = down;
    end
    
    if stimulus_matrix(trial,4,run) == 1
        thick = up;
    else
        thick = down;
    end
    
    
% RENDER FIXATION POINT

Screen('FillOval', win, white, ...
    [center_h - fix_rad; center_v - fix_rad; ...
    center_h + fix_rad; center_v + fix_rad], 2*fix_rad);

if dev_text
    RunTrial = sprintf('Run:%d Trial:%d', run, trial);
    DrawFormattedText(win, RunTrial, 'left', 'center');
end
    
Screen('Flip', win);
WaitSecs(2);


% RENDER CUE

if side == 3
    cue_color = black;
else
    if neglect == left % left-neglect
        if side == left
            cue_color = yellow;
        else
            cue_color = white;
        end
    elseif neglect == right % right-neglect
        if side == right
            cue_color = yellow;
        else
            cue_color = white;
        end
    else % no neglect
        cue_color = white;
    end
end

for i = 0:cue_frames-1 % frames in 1 cue
    pos_h = center_h + side*dist_h;
    pos_v = center_v + direction*speed*i; % move vertically

    cue = [pos_h - cue_rad; pos_v - cue_rad; pos_h + cue_rad; pos_v + cue_rad];

    Screen('FillRect', win, cue_color, cue );    
    Screen('Flip', win);
    
    if i == 0
        data(trial,2,run) = GetSecs;
    end

    if dev_text
        DrawFormattedText(win, RunTrial, 'left', 'center');
    end
end

data(trial,3,run) = GetSecs;

%% RENDER TARGET

% targ_side = down; % where the target appears
% thick = up; % which side is thick

if targ_side == up;
    targ2 = targ2_up;
    if thick == up;
        targ1 = targ1_up_top;
    else
        targ1 = targ1_up_bot;
    end
else
    targ2 = targ2_dn;
    if thick == up;
        targ1 = targ1_dn_top;
    else
        targ1 = targ1_dn_bot;
    end
end

Screen('FillOval', win, white, targ1);
Screen('FillOval', win, black, targ2);
Screen('Flip', win);

data(trial,4,run) = GetSecs;

start_target = GetSecs;
while GetSecs - start_target < time_per_target;
    
    if dev_text
        DrawFormattedText(win, RunTrial, 'left', 'center');
    end
    
    [key_press,~,key_code] = KbCheck(-1);
    if key_press 
        if key_code(UpKey) && data(trial,1,run) == 0;
            data(trial,1,run) = up;
            data(trial,6,run) = GetSecs; % response time
        elseif key_code(DownKey) && data(trial,1,run) == 0;
            data(trial,1,run) = down;
            data(trial,6,run) = GetSecs; % response time
        end
    end
end

%% Intertrial interval

ITI = (rand*(max_ITI - min_ITI)) + min_ITI;
Screen('Flip', win);

data(trial,5,run) = GetSecs;

start_ITI = GetSecs;
while GetSecs - start_ITI < ITI;
    
    [key_press,~,key_code] = KbCheck(-1);
    if key_press 
        if key_code(UpKey) && data(trial,1,run) == 0;
            data(trial,1,run) = up;
            data(trial,6,run) = GetSecs; % response time
        elseif key_code(DownKey) && data(trial,1,run) == 0;
            data(trial,1,run) = down;
            data(trial,6,run) = GetSecs; % response time
        end
    end
end

data(trial,7,run) = GetSecs;
    
end


if run < N_runs;
    EndRun = sprintf('End of Run %d.\nPress any key to begin Run %d.', run, run+1);
else
    EndRun = 'End of task.\nPress any key to exit.';
end


DrawFormattedText(win, EndRun, 'center', 'center');
Screen('Flip', win);

bWaiting = true;
while bWaiting
    [bKey_press] = KbCheck(-1);
    bWaiting = ~(bKey_press);
end

end

    
%% END

Screen('Flip', win)
WaitSecs(time_per_target);

Screen('CloseAll') % Close Screen at end of process

time_end = GetSecs;
time_elapsed = (time_end - time_start)/60

save(sFile_name,'data','counterbalanced_matrix','stimulus_matrix')

readstats(sFile_name);
end
