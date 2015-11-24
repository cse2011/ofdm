function y = cs_threshold(x, N, fs, M, fc, BW)
%%%%% ����˵�� %%%%%
% x -- �ź�
% N -- ѭ���׼��������ȣ�����С�ڵ����ź����г���
% fs -- ����Ƶ��, ������Ϊ-fs/2��fs/2
% M -- ƽ������, ʱ��ֱ���*Ƶ�ʷֱ���=M
% BW -- �źŴ���
%%%%%%%%%%%%%%%%%%%

%%% ���� %%% 
win = 'hamming'; % ƽ��������

d_alpha = fs/N; % 1/ʱ��ֱ���=ѭ��Ƶ�ʷֱ���
alpha = 0:d_alpha:fs; % ѭ��Ƶ��, �ֱ���=1/ʱ��ֱ���
a_len = length(alpha); % ѭ��Ƶ��ȡ������

f_len = floor(N/M-1)+1; % ���ƽ��������, ��Ƶ�ʲ�������
f = -(fs/2-d_alpha*floor(M/2)) + d_alpha*M*(0:f_len-1); % Ƶ�ʲ�����λ��

S = zeros(a_len, f_len); % ��ʼ��ع�����
i = 1; 

fl = ceil((2*fc-BW)/d_alpha)+1; % ������a���������
rt = floor((2*fc+BW)/d_alpha)+1; % ������a���������
peak_a = fl:rt; % a�ļ�ⷶΧ
peak_f = (1:ceil(BW/d_alpha/M))+floor(f_len/2-floor(BW/d_alpha/M)/2); % f������ⷶΧ
noise_n = 0; % ����������ʼ

%%% �ź�fft�任 %%%
X = fftshift(fft(x(1:N))); 
X = X';

%%% ����ѭ��Ƶ��ȡֵ %%%
for alfa = alpha   
    
    if i >= fl && i <= rt % ���������a��Χ
        
        interval_f_N = round(alfa/d_alpha); % ѭ��Ƶ������Ӧ��Ƶ���������
        f_N = floor((N-interval_f_N-M)/M)+1; % ƽ�����ĸ���
    
        %%% ����ƽ�������� %%%
        g = feval(win, M); 
        window_M = g(:, ones(f_N,1));
    
        %%% Ƶ������ƽ��ģ�� %%%
        t = 1:M*f_N;
        t = reshape(t, M, f_N);
    
        %%% ����X1,X2 %%%
        X1 = X(t).*window_M;
        X2 = X(t+interval_f_N).*window_M; 

        %%% ��������� %%%
        St = conj(X1).*X2;
        St = mean(St, 1); % ƽ��ƽ��
    
        noise_n = noise_n + length(St); % �ۼ�������
        S(i, floor((f_len-f_N)/2)+(1:f_N)) = St/N; % �����ƽ�������������Ա���ͼ
    end
    
    i = i+1; 
end
%%% ����ѭ��Ƶ��ȡֵ���� %%%
 
%%% ѭ����������ͼ %%%
%mesh(f, alpha, abs(S)); 
%axis tight;
%title('BPSK-OFDM');
%xlabel('f'); ylabel('a');

peak = S(peak_a, peak_f); % ȡ����ֵ����
S(peak_a, peak_f) = 0; 
noise = S(peak_a,:); % ȡ���������� 

p = sort(abs(peak(:)),'descend'); % �����ֵ����
peak_mean = mean(p(1:ceil(length(p)*0.1))); % ǰ10%��ƽ��

noise_n = noise_n-length(peak(:)); % ʵ����������
n = sort(abs(noise(:)),'descend'); % ������������
noise_mean = mean(n(1:noise_n)); % ����ƽ��

y = peak_mean/noise_mean; % �����ֵ