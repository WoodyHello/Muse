function [r_est, ...
          mse_grid, ...
          x_grid, ...
          y_grid, ...
          date_str_this, ...
          letter_str_this, ...
          i_syl_this, ...
          r_head,r_tail, ...
          R, ...
          mse_min, ...
          mse_crit, ...
          mse_body, ...
          ms_total, ...
          a, ...
          N, ...
          N_filt]= ...
  r_est_random_multiple_trials(base_dir_name, ...
                        data_analysis_dir_name, ...
                        date_str, ...
                        letter_str, ...
                        conf_level, ...
                        verbosity)

% base_dir_name a string
% date_str, letter_str each a cell array of strings

n_trials=length(date_str);
i_trial=randi(n_trials,1);
date_str_this=date_str{i_trial};
letter_str_this=letter_str{i_trial};
[r_est,mse_grid,x_grid,y_grid,i_syl_this,r_head,r_tail,R, ...
 mse_min,mse_crit,mse_body,ms_total, ...
 a,N,N_filt]= ...
  r_est_random_from_trial_indicators(base_dir_name, ...
                                     data_analysis_dir_name, ...
                                     date_str_this, ...
                                     letter_str_this, ...
                                     conf_level, ...
                                     verbosity);

end
