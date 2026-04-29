%Disclaimer: Access to raw data is required to run code. Data will be made
%   available upon resonable request.
%
%Description: This function creates a visualization for raw LFP, filtered
%   LFP, and the corresponding spectrogram. The user must define the file
%   to load for the given LFP data and the time stamp for generating the
%   figure. This code was used to generate Figure 1, panel E.
%
%Input:
%   raw data file containing lfp and sfreq
%       lfp - a 1 x n vector of lfp time series data
%       sfreq - the sampling frequency of lfp

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%% Load in the raw LFP data

%%%% LOAD RAW DATA FILE %%%%

%% Manually define which time point to plot

%Downsample as desired
factor = 1;
dEDF = downsample(lfp',factor); %downsampled time series data
Fs = sfreq/factor; %downsampled sampling frequency

%Define time axis
tEDF = transpose((1:size(dEDF,1))/Fs);

%Define start time in seconds
time_start = 3449.5;

%Define end time in seconds
time_end = time_start + 1;

%Get the start and end indices
start_idx = time_start * Fs;
end_idx = time_end * Fs;

%Define x-axis for plotting
xlim_plt = [tEDF(start_idx),tEDF(end_idx)];

%Design the filter and filter time series data
fNQ = Fs/2;                                        	%Define Nyquist frequeuncy.
d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',...
    (60)/fNQ,...                                        %Freq @ edge first stop band.
    (100)/fNQ,...                                       %Freq @ edge of start of passband.
    (300)/fNQ,...                                       %Freq @ edge of end of passband
    (350)/fNQ,...                                       %Freq @ edge second stop band
    80,...                                              %Attenuation in the first stop band in decibels
    0.1,...                                         	%Amount of ripple allowed in the pass band.
    40);                                                %Attenuation in the second stop band in decibels
Hd = design(d,'equiripple');                         	%Design the filter
[num, den] = tf(Hd);                               	%Convert filter to numerator, denominator expression.
order = length(num);                                	%Get filter order.

dfilt = filter(num, den, dEDF);                                    %Filter it.
dfilt = [dfilt(floor(order/2)+1:end); zeros(floor(order/2),1)];   %Shift after filtering.

dspec = dEDF(start_idx:end_idx);
dspec = dspec - mean(dspec);
t     = tEDF(start_idx:end_idx);

%Compute spectrogram with Hanning taper
params.Fs    = Fs;             % Sampling frequency [Hz]
params.fpass = [30 250];       % Frequencies to visualize in spectra [Hz]
movingwin    = [0.200,0.005];  % Window size, Step size [s]
params.tEDF  = t; %time axis
[S0,S_times,S_freq] = hannspecgramc(dspec,movingwin,params);

%Smooth the spectra
t_smooth = 11;%31;
dt_S     = S_times(2)-S_times(1);
myfilter = fspecial('gaussian',[1 t_smooth], 1);
S_smooth = imfilter(S0, myfilter, 'replicate');   % Smooth the spectrum.

%% Plot example biomarker

%Initialize figure
figure
tiledlayout(4,1)

%Plot time series data
nexttile([2,1])
plot(tEDF(start_idx:end_idx),dEDF(start_idx:end_idx))
xlabel('Time (s)')
xlim(xlim_plt)

%Plot filtered time series
nexttile
plot(tEDF(start_idx:end_idx),dfilt(start_idx:end_idx))
xlabel('Time (s)')
xlim(xlim_plt)

%Plot the spectrogram
nexttile
colormap(jet)
imagesc(S_times,S_freq,log10(S_smooth)')  %, [-3 -0.5])
axis xy
xlabel('Time (s)')
xlim(xlim_plt)

%Set the dimensions of the figure
set(gcf,'position',[100,100,250,500])