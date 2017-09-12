%% Read Data
function readstats(filename)

load(filename);

% DATA
% 1 - up/down response
% 2 - cue onset
% 3 - cue offset
% 4 - target onset
% 5 - target offset
% 6 - response time
% 7 - ITI

% STIMULUS MATRIX
% 1 - aware/unaware
% 2 - cue movement direction
% 3 - target location
% 4 - thick top/bottom

N_trials = size(data,1);
N_runs = size(data,3);
N = N_trials*N_runs; % total number of trials in data

up = -1;
down = 1;

i = 0;
for run = 1:N_runs;
    for trial = 1:N_trials;
        i = i + 1;
        twoD_data(i,:) = data(trial,:,run);
        stims(i,:) = stimulus_matrix(trial,:,run);
        if stims(i,4) == 1
            stim_thick(i) = up;
        else
            stim_thick(i) = down;
        end
    end
end


responses      = twoD_data(:,1);
cue_times      = twoD_data(:,3) - twoD_data(:,2);
target_times   = twoD_data(:,5) - twoD_data(:,4);
response_times = twoD_data(:,6) - twoD_data(:,4);
ITI_times      = twoD_data(:,7);

% cue_aware     = stims(:,1);
cue_direction   = stims(:,2);
target_location = stims(:,3);

cue_exist = stims(:,1) ~= 3; % 1 if cue present, 0 if no cue

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
agg_mean = mean(response_times);
agg_std = std(response_times);
not_outlier = abs(response_times - agg_mean) < 3*agg_std;

align_trial = cue_direction == target_location & cue_exist;
misalign_trial = cue_direction ~= target_location & cue_exist;
nocue_trial = ~cue_exist;

accurate_trial = stim_thick' == responses;
align_rt = response_times(align_trial & accurate_trial & not_outlier);
misalign_rt = response_times(misalign_trial & accurate_trial & not_outlier);
nocue_rt = response_times(nocue_trial & accurate_trial & not_outlier);


% ACCURACY

% overall accuracy
accuracy = sum(accurate_trial)/size(accurate_trial,1);

% accuracy in 3 different conditions
acc_con(1) = sum(align_trial & accurate_trial) / (N/3);
acc_con(2) = sum(misalign_trial & accurate_trial) / (N/3);
acc_con(3) = sum(nocue_trial & accurate_trial) / (N/3);

disp('overall accuracy:');
disp(accuracy);
disp('aligned accuracy:');
disp(acc_con(1));
disp('misaligned accuracy:');
disp(acc_con(2));
disp('no cue accuracy:');
disp(acc_con(3));

bin_con(1,:) = binomial_mean(acc_con(1), N/3);
bin_con(2,:) = binomial_mean(acc_con(2), N/3);
bin_con(3,:) = binomial_mean(acc_con(3), N/3);

disp('cue time (seconds) = ');
disp(mean(data(:,3,1)-data(:,2,1)));

% PLOTS

mean_rt(1) = mean(align_rt);
mean_rt(2) = mean(misalign_rt);
mean_rt(3) = mean(nocue_rt);
SE_rt(1) = std(align_rt,0) / sqrt(size(align_rt,1));
SE_rt(2) = std(misalign_rt,0) / sqrt(size(misalign_rt,1));
SE_rt(3) = std(nocue_rt,0) / sqrt(size(nocue_rt,1));

close all % close any figures still open from previous functions
figure
errorbar(mean_rt, SE_rt)
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
ylabel('response time (s)')

figure
errorbar(acc_con, bin_con(:,2))
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
ylabel('accuracy')
axis([0,4,0,1])

figure
hist(align_rt,30)
title('aligned')

figure
hist(misalign_rt,30)
title('misaligned')

figure
hist(response_times(accurate_trial),30)
title('all trials')

end