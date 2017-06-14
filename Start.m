%% ʵʱ������Գ���ϵͳ
clear;clc;close all;
warning off; %#ok<*WNOFF>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ע�⣺�޸Ĳ�����ɾ��InitDelta.mat�ļ�����Ӳ���ʱ����ɾ����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% OTC ���۲������� ����ֻ���ں����item����
ud.code    = {'M1709.DCE'; 'M1709.DCE'; 'C1709.DCE'; 'C1709.DCE'}; % ����ʲ����룻��ϸ�ɲο��ļ����ڻ����Wind�б�.pdf
ud.side    = {'sellcall'; 'sellcall'; 'sellcall'; 'sellcall'};         % ���׷���sellcall, buycall, sellput, buyput
ud.strike  = [2705; 2705; 1650; 1650];                        % ִ�м۸�
ud.exercisedates = {'2017-8-23'; '2017-8-23'; '2017-8-23'; '2017-8-23'}; % ��Ȩ����
ud.type    = [3; 1; 3; 1];        % ��Ȩ���ͣ�European:1  American:2  Asian:3  Binary:4
ud.premium = [1.1; 1.1; 1.1; 1.1]; % ��Ȩ����ʱ�����ʵ���۷���
ud.yield   = [0; 0; 0; 0];        % ��Ʊ��Ȩ��Ϣ����ʱ����������ʽ��Ȩ
%% �Գ��������
ud.hedge    = [1; 0; 1; 0];            % �Ƿ�Գ�����: 0/1
ud.volume   = [9; 9; 30; 30];      % ������
ud.ordinaryDelta = [0.2; 0.2; 0.2; 0.2]; % �ճ�Delta�䶯��ֵ
ud.lastweekDelta = [0.15; 0.25; 0.15; 0.25]; % ���һ��Delta�䶯��ֵ
ud.lastdayDelta  = [0.1; 0.3; 0.1; 0.3]; % ���һ��Delta�䶯��ֵ

%% ��ʽ��Ȩ�Ͷ�Ԫ��Ȩ�������ã�
ud.settle = { '2017-5-23';  '2017-5-23'; '2017-5-23'; '2017-5-23'}; % ǩԼ���ڣ�ֻ�����ڶ�Ԫ��Ȩ����ʽ��Ȩ

%% ��Ԫ��Ȩ�������ã����Ƕ�Ԫ��Ȩ����Ϊ0
ud.pCStrike = [0.95; 0.95; 1.05; 1];    % Call Strike�䶯����
ud.pPStrike = [1.05; 0.95; 0.95; 1];    % Put Strike�䶯����
ud.pCash    = [0.05; 0.05; 0.05; 1];    % ֧����ռ�ּ۵ı���
% ���½����ڶ�Ԫ��Ȩ�Գ�
ud.settleprice = [2888; 6888; 4388; 3150]; % ��Ԫ��ȨǩԼʱ�ı�ļ۸�

%% ��ز�������
t = timer;
t.Name     = 'HedgeTimer';
t.UserData = ud;              % ��������
t.TimerFcn = @DynamicHedge;
t.Period   = 300;             % ִ��������ʱ��
t.ExecutionMode = 'fixedrate';  

%t.TasksToExecute = 1;        % ������Գ壬��ֵ����һ��

%% Start/Stop
start(t);
%pause(3600*3);
%{
stop(t)     % ֹͣ���
%}