function multidata(outFile)

% outFile = name of output file (string)

subject = 0;
loop = true;
STOP = {'stop','STOP'};
stop = {'stop','STOP'};
while loop
    filename = input('Filename? (Type STOP when done)\n');
    if sum(strcmp(filename, stop)) > 0;
        loop = false;
    else
        subject = subject+1;
        
        load(filename);
     
        % 4-dimensional data matrix, contains all data
        N_trials = size(data,1);
        N_runs = size(data,3);
        i = 0;
        for run = 1:N_runs;
            for trial = 1:N_trials;
                i = i + 1;
                mData(i,:,subject) = data(trial,:,run);
                mStim(i,:,subject) = stimulus_matrix(trial,:,run);
            end
        end
        
    end
end

save(outFile,'mData','mStim');

end