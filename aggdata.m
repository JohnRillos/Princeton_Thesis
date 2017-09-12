function multistats(multi)
load(multi)

N_subjects = size(mData,3);

N_trials = size(mData,1);
%N = N_trials*N_runs; % total number of trials in data

up = -1;
down = 1;

for subject = 1:N_subjects
    
    for trial = 1:N_trials
        if mStim(trial,4,subject) == 1
            stim_thick(trial) = up;
        else
            stim_thick(trial) = down;
        end
    end
    
    responses      = mData(:,1,subject);
    cue_times      = mData(:,3,subject) - mData(:,2,subject);
    target_times   = mData(:,5,subject) - mData(:,4,subject);
    response_times = mData(:,6,subject) - mData(:,4,subject);
    ITI_times      = mData(:,7,subject);
    
    % cue_aware     = stims(:,1);
    cue_direction   = mStim(:,2,subject);
    target_location = mStim(:,3,subject);
    
    cue_exist = mStim(:,1,subject) ~= 3; % 1 if cue present, 0 if no cue
    
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
    acc_con(1,subject) = sum(align_trial & accurate_trial) / (N_trials/3);
    acc_con(2,subject) = sum(misalign_trial & accurate_trial) / (N_trials/3);
    acc_con(3,subject) = sum(nocue_trial & accurate_trial) / (N_trials/3);
    
%     bin_con(1,:) = binomial_mean(acc_con(1), N/3);
%     bin_con(2,:) = binomial_mean(acc_con(2), N/3);
%     bin_con(3,:) = binomial_mean(acc_con(3), N/3);
    
    
    % RECORD INFO
    
    mean_rt(1,subject) = mean(align_rt);
    mean_rt(2,subject) = mean(misalign_rt);
    mean_rt(3,subject) = mean(nocue_rt);
%     SE_rt(1,subject) = std(align_rt,0) / sqrt(size(align_rt,1));
%     SE_rt(2,subject) = std(misalign_rt,0) / sqrt(size(misalign_rt,1));
%     SE_rt(3,subject) = std(nocue_rt,0) / sqrt(size(nocue_rt,1));
    
end

multi_mean 

end