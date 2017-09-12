function multistats(multi)
load(multi)

N_subjects = size(mData,3);

N_trials = size(mData,1);

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
    SE_rt(1,subject) = std(align_rt,0) / sqrt(size(align_rt,1));
    SE_rt(2,subject) = std(misalign_rt,0) / sqrt(size(misalign_rt,1));
    SE_rt(3,subject) = std(nocue_rt,0) / sqrt(size(nocue_rt,1));
    
    % CALCULATE MISALIGNED - ALIGNED DIFFERENCE
    diff_rt(subject) = mean_rt(2,subject) - mean_rt(1,subject); 
    
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

mean_rt(1,:)'
mean_rt(2,:)'
mean_rt(3,:)'
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


% DIFF
diff_mean = mean(diff_rt)
% diff_SD = std(diff_rt)
diff_SE = std(diff_rt)/sqrt(N_subjects)
[h,p] = ttest(mean_rt(2,:), mean_rt(1,:))

Xd = mean_rt(2,:) - mean_rt(1,:)
t = mean(Xd)/(std(Xd)/sqrt(N_subjects))

hypo_confirm = diff_rt > diff_SE;
hypo_reject = -(diff_rt < -diff_SE);
hypo_test = hypo_confirm + hypo_reject
hypo_confirm_quotient = sum(hypo_confirm/N_subjects)
hypo_quotient = sum(hypo_test)/N_subjects


close all % close any figures still open from previous functions
% figure
% errorbar(multi_mean, multi_SE)
% set(gca,'XTick',1:3)
% set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
% ylabel('response time (s)')
% title('Mean RT vs condition w/ Standard Error of mean RTs');

figure('Position', [350, 400, 500, 400])
hold on
plot([0.5 2.5],[multi_mean(3) multi_mean(3)]*1000,'k--','LineWidth',1);
errorbar(multi_mean(1:2)*1000, multi_SE(1:2)*1000)
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'aligned cue','misaligned cue'})
ylabel('response time (ms)')
title('Aggregate Mean RT vs condition w/ Standard Error');
legend('no cue')

figure('Position', [900, 200, 400, 600]);
hold on
for i = 1:N_subjects
    plot([1 2],[mean_rt(1,i) mean_rt(2,i)]*1000,'o-','LineWidth',1);
end
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'aligned cue','misaligned cue'})
ylabel('response time (ms)')
axis([0.75,2.25,0.5*1000,0.9*1000])
title('per Subject Mean RT vs condition');

figure('Position', [1350, 400, 500, 400])
hold on
hist(diff_rt*1000,20)
plot([0 0],[0 3],'r--','LineWidth',2);
plot([diff_mean diff_mean]*1000,[0 3],'g','LineWidth',2);
ax = gca;
ax.XTick = [-20:5:50];
xlabel('misaligned RT - aligned RT (ms)')
ylabel('# of subjects')
title('Difference Scores: Measure of Distracting Effect')

% figure
% errorbar(multi_mean, multi_avg_SE)
% set(gca,'XTick',1:3)
% set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
% ylabel('response time (s)')
% title('Mean RT vs condition w/ average Standard Error');

figure
errorbar(multi_acc, multi_acc_SE)
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'aligned','misaligned','no cue'})
ylabel('mean accuracy')
axis([0,4,0,1])
title('Accuracy vs condition w/ Standard Error');

multi_acc
multi_acc_SE

% figure
% plot(diff_rt,'o')
% title('Misaligned - Aligned RTs')
% xlabel('subject #')
% ylabel('difference (seconds)')
% hold on
% plot([0 N_subjects+1],[0 0],'k','LineWidth',2);
% plot([0 N_subjects+1],[diff_mean diff_mean],'r','LineWidth',3);
% plot([0 N_subjects+1],[diff_mean-diff_SE diff_mean-diff_SE],'r--','LineWidth',1);
% plot([0 N_subjects+1],[diff_mean+diff_SE diff_mean+diff_SE],'r--','LineWidth',1);

hold off

end