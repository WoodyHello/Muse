exp_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test/sys_test_06132012';
letter_str='D';
i_segment_start=10547488;  % Voc130 from ax, voc51 after snippetization
i_segment_end=10558880;  % these are both matlab-style indices
fs=450450;  % Hz, happen to know this a priori
dt=1/fs;  % s
start_pad_duration_want=0.010;  % s
end_pad_duration_want=0.010;  % s
samples_in_start_pad=ceil(start_pad_duration_want/dt);
samples_in_end_pad=ceil(end_pad_duration_want/dt);
i_start=i_segment_start-samples_in_start_pad; 
i_end=i_segment_end+samples_in_end_pad;

[v,t] = ...
  read_voc_audio_trace( exp_dir_name, letter_str, ...
                        i_start,i_end);
[N,n_mics]=size(v);                      

% returned t starts at zero, want zero to be segment start
t=t-dt*samples_in_start_pad;

clr_mike=[1 0 0 ; ...
          0 0.7 0 ; ...
          0 0 1 ; ...
          0 0.8 0.8 ];

% set up the figure and place all the axes                                   
w_fig=2.5; % in
h_fig=3; % in
n_row=n_mics;
n_col=1;
w_axes=1.5;  % in
h_axes=0.5;  % in
w_space=1;  % in (not used)
h_space=0;  % in                              
[figure_handle,subplot_handles]= ...
  layout_axes_grid(w_fig,h_fig,...
                   n_row,n_col,...
                   w_axes,h_axes,...
                   w_space,h_space);
set(figure_handle,'color','w');                               

% plot the filtered clips with raw in background
white_fraction=0.75;
%figure_handle=figure('color','w');
%set_figure_size_explicit(figure_handle,[3 6]);
for i_mic=1:n_mics
  subplot_handle=subplot_handles(i_mic);
  axes(subplot_handle);  %#ok
  %plot(1000*t,1000*v(:,i_mic)     ,'color',(1-white_fraction)*clr_mike(i_mic,:)+white_fraction*[1 1 1]);
  plot(1000*t,1000*v(:,i_mic)     ,'color',clr_mike(i_mic,:));
  %hold on
  %plot(1000*t,1000*v_filt(:,i_mic),'color',clr_mike(i_mic,:));
  %hold off
  set(subplot_handle,'fontsize',7);
  ylim(ylim_tight(1000*v(:,i_mic)));
  %ylabel(sprintf('Mic %d',i_mic),'fontsize',7);
  if i_mic~=n_mics ,
    set(subplot_handle,'xticklabel',{});
    set(subplot_handle,'yticklabel',{});
  else
    set(subplot_handle,'yAxisLocation','right');
  end
end
xlabel('Time (ms)','fontsize',7);
ylim_all_same();
tl(1000*t(1),1000*t(end));

% add brackets to show the actual segment
t_segment_start_relative=0;
t_segment_end_relative=(i_segment_end-i_segment_start)*dt;
drawnow;
for i_mic=1:n_mics
  subplot_handle=subplot_handles(i_mic);
  yl=get(subplot_handle,'ylim');
  line('parent',subplot_handle, ...
       'xdata',1000*t_segment_start_relative*[1 1], ...
       'ydata',yl, ...
       'color','k');
  line('parent',subplot_handle, ...
       'xdata',1000*t_segment_end_relative*[1 1], ...
       'ydata',yl, ...
       'color','k');
end

% write to a .tcs file
name=cell(n_mics,1);
units=cell(n_mics,1);
for i_mic=1:n_mics
  name{i_mic}=sprintf('Mic %d',i_mic);
  units{i_mic}='mV';
end
write_tcs_common_timeline('example_voc.tcs',name,t,1000*v,units);

% played around in Groundswell, found good Spectrogram params
T_window_want=0.002;  % s 
dt_window_want=T_window_want/10;
NW=2;
K=3;
f_max_keep=120e3;  % Hz
p_FFT_extra=2;

% calc spectrogram
for i_mic=1:n_mics
  [f_S,t_S,~,S_this,~,~,N_fft,W_smear_fw]=...
    powgram_mt(dt,v(:,i_mic),...
               T_window_want,dt_window_want,...
               NW,K,f_max_keep,...
               p_FFT_extra);  
  if i_mic==1 , 
    S=zeros(length(f_S),length(t_S),n_mics);
  end
  S(:,:,i_mic)=S_this;  % V^2/Hz
end
N_fft  %#ok
W_smear_fw  %#ok
t_S=t_S+t(1);  % powgram_mt only knows dt, so have to do this           
S_log=log(S);  % Spectrogram expects this
%var_est=std(data_short_cent)^2;

% set up the figure and place all the axes                                   
w_fig=2.5; % in
h_fig=3; % in
n_row=n_mics;
n_col=1;
w_axes=1.5;  % in
h_axes=0.5;  % in
w_space=1;  % in (not used)
h_space=0;  % in                              
[figure_handle,subplot_handles]= ...
  layout_axes_grid(w_fig,h_fig,...
                   n_row,n_col,...
                   w_axes,h_axes,...
                   w_space,h_space);
set(figure_handle,'color','w');                               

% plot the spectrograms
S_max=max(max(max(S)))  %#ok
title_str='';
for i_mic=1:n_mics ,
  subplot_handle=subplot_handles(i_mic);
  axes(subplot_handle);  %#ok
  plot_powgram(1000*t_S,f_S,1e9*S(:,:,i_mic),...
               [],[],[],...
               'amplitude',[0 80],...
               title_str);  % convert to mV^2/kHz
  set(subplot_handle,'fontsize',7);
  %ylim(ylim_tight(1000*v(:,i_mic)));
  %ylabel(sprintf('Mic %d',i_mic),'fontsize',7);
  set(subplot_handle,'yAxisLocation','right');
  set(subplot_handle,'yticklabel',{});
  ylabel(subplot_handle,'');
  if i_mic~=n_mics ,
    set(subplot_handle,'xticklabel',{});
  else
    colorbar_handle=add_colorbar(subplot_handle,0.1,0.075);
    set(colorbar_handle,'fontsize',7);
    ylabel(colorbar_handle,'Amp density (mV/kHz^{0.5})');
    set(colorbar_handle,'ytick',[0 80]);
  end
end
colormap(subplot_handle,flipud(gray(256)));
xlabel(subplot_handle,'Time (ms)','fontsize',7);
%ylim_all_same();
%tl(1000*t(1),1000*t(end));

% load the snippets determined by Josh's code
snippet_file_name=fullfile(exp_dir_name, ...
                           'Data_analysis10', ...
                           sprintf('Test_%s_1_Mouse.mat',letter_str));
snippet_file_contents=load(snippet_file_name);
snippets=snippet_file_contents.mouse;
i_example_segment=51;  % 
is_example_segment= ([snippets.index]==i_example_segment) ;
example_snippets=snippets(is_example_segment);

% draw rectangles for each snippet on all the spectrograms
i_mic_to_show_snippets_on=4;
n_example_snippets=length(example_snippets);
t_segment_start=dt*(i_segment_start-1);
for i_example_snippet=1:n_example_snippets
  this_snippet=example_snippets(i_example_snippet);
  t_lo=dt*(this_snippet.start_sample_fine-1);  %s
  t_hi=dt*(this_snippet.stop_sample_fine-1);  %s
  t_lo_rel=t_lo-t_segment_start;  %s
  t_hi_rel=t_hi-t_segment_start;  %s
  f_lo=this_snippet.lf_fine;
  f_hi=this_snippet.hf_fine;
  for i_mic=i_mic_to_show_snippets_on ,
    line('parent',subplot_handles(i_mic), ...
         'xdata',1000*[t_lo_rel t_hi_rel t_hi_rel t_lo_rel t_lo_rel], ...
         'ydata',[f_lo f_lo f_hi f_hi f_lo], ...
         'linewidth',0.25, ...
         'color',[0 0 0.7]);
  end
end



