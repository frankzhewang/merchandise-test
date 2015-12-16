% Matlab script
% Summarize expected profit under various policies for three-store problem

fprintf('Summarizing profits with timing info ...\n');
summarize_timing
fprintf('Done.\n')

fprintf('Summarizing profits without timing info ...\n');
summarize_no_timing
fprintf('Done.\n')

fprintf('Summarizing profits using mismatched optimal policies ...\n');
summarize_mismatch
fprintf('Done.\n')

