function multiruns(multi)
load(multi)

N_subjects = size(mData,3);

N_trials = size(mData,1);

N_runs = 9;
run_size = N_trials/N_runs; % = 24

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
    
    % RECORD INFO
    
    for run = 1:N_runs
        index = (run*run_size-run_size+1):run*run_size; % FIX THIS
        size(align_rt,1) % not all categories have same # of trials
        size(misalign_rt,1)
        size(nocue_rt,1)
        mean_rt(1,subject,run) = mean(align_rt(index));
        mean_rt(2,subject,run) = mean(misalign_rt(index));
        mean_rt(3,subject,run) = mean(nocue_rt(index));
        SE_rt(1,subject,run) = std(align_rt(index),0) / sqrt(N_subjects);
        SE_rt(2,subject,run) = std(misalign_rt(index),0) / sqrt(N_subjects);
        SE_rt(3,subject,run) = std(nocue_rt(index),0) / sqrt(N_subjects);
    end
    
end

multi_mean(1) = mean(mean_rt(1,:));
multi_mean(2) = mean(mean_rt(2,:));
multi_mean(3) = mean(mean_rt(3,:));
% Standard Error of mean RT's
multi_SE(1) = std(mean_rt(1,:))/sqrt(N_subjects);
multi_SE(2) = std(mean_rt(2,:))/sqrt(N_subjects);
multi_SE(3) = std(mean_rt(3,:))/sqrt(N_subjects);
% average of Standard Errors of RT's
multi_avg_SE(1) = mean(SE_rt(1,:));
multi_avg_SE(2) = mean(SE_rt(2,:));
multi_avg_SE(3) = mean(SE_rt(3,:));

mean_rt
multi_mean
multi_SE
multi_avg_SE
N_subjects

multi_acc(1) = mean(acc_con(1,:));
multi_acc(2) = mean(acc_con(2,:));
multi_acc(3) = mean(acc_con(3,:));
multi_acc_SE(1,:) = std(acc_con(1,:))/sqrt(N_subjects);
multi_acc_SE(2,:) = std(acc_con(2,:))/sqrt(N_subjects);
multi_acc_SE(3,:) = std(acc_con(3,:))/sqrt(N_subjects);



close all % close any figures still open from previous functions
figure
errorbar(multi_mean, multi_SE)
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
ylabel('response time (s)')
title('Mean RT vs condition w/ Standard Error of mean RTs');

figure
errorbar(multi_mean, multi_avg_SE)
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
ylabel('response time (s)')
title('Mean RT vs condition w/ average Standard Error');

figure
errorbar(multi_acc, multi_acc_SE)
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
ylabel('accuracy')
axis([0,4,0,1])
title('Accuracy vs condition w/ Standard Error');

end