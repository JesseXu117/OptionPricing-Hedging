%% Real-time hedge
clear;clc;close all;
%w = windmatlab;

%% Hedge parameter setting---OTC
Code    = 'M1709.DCE';  % Code of underlying asset
Side    = 'sellcall'; % Side: sellcall,sellput,buycall,buyput
Strike  = 2712;      % Strike price
Type    = 4;         % Type of option   European:1  American:2  Asian:3  Binary:4
Premium = 1.1;       % ��Ȩ����ʱ�����ʵ���۷���
Yield   = 0;
%% parameter of binary option
pCStrike    = 0.95;   % Call Strike�䶯����
pPStrike    = 1.05;   % Put Strike�䶯����
pCash       = 0.05;   % ֧����ռ�ּ۵ı���
SettlePrice = 6888;   %��Ԫ��ȨǩԼʱ�ı�ļ۸�
%% ��ʽ��Ȩ
Settle = '2017-5-24';        % ǩԼ����
ExerciseDates = '2017-8-24'; % ��Ȩ����

Time = (datenum(ExerciseDates)-datenum(today))/365;

%% (����)Ԥ��������
%Price = w.wsq(Code,'rt_last');   % �ڻ����¼۸�
Price = 2661;
%Rate  = w.wsq('CGB1Y.WI','rt_last')/100; % SHIBOR����
Rate = 0.03;
%[EstVol,GarchVol,SellVol,BuyVol] = EstVolatility(Code);

%PremiumVol = Premium*max(GarchVol,SellVol);
PremiumVol = 0.27;
%DiscountVol = (2-Premium)*min(GarchVol,BuyVol);
DiscountVol = 0.27;
%fprintf('��ʷ��ֵ���ƵĲ�����Ϊ %f\n',EstVol);
%fprintf('GARCHģ�͹��ƵĲ�����Ϊ %f\n',GarchVol);

% if strcmp(Side,'sellcall') || strcmp(Side,'sellput')
%     fprintf('������Ȩ�����ƵĲ�����Ϊ %f\n',SellVol);
%     fprintf('������Ȩʱ������ʹ�ò�����Ϊ %f\n\n',PremiumVol);
     Volatility = PremiumVol;
     EstVol = 0.27;
% elseif strcmp(Side,'buycall') || strcmp(Side,'buyput')
%     fprintf('������Ȩ�����ƵĲ�����Ϊ %f\n',BuyVol);
%     fprintf('������Ȩʱ������ʹ�ò�����Ϊ %f\n\n',DiscountVol);
%     Volatility = DiscountVol;
% end

%% �߼��ж�
if Type == 1
    [CallPrice,PutPrice] = blsprice(Price, Strike, Rate, Time, Volatility,Yield);
    if strcmp(Side,'buycall') || strcmp(Side,'sellcall')
        OurPrice = CallPrice;
    elseif strcmp(Side,'buyput') || strcmp(Side,'sellput')
        OurPrice = PutPrice;
    end
    fprintf('���ǶԸ�ŷʽ��Ȩ�Ķ���Ϊ��%f\n',OurPrice);
    
    [CallDelta,PutDelta,Gamma,CallTheta,PutTheta,Vega,CallRho,PutRho] ...
    = BS_GreekLetters(Price,Strike,Rate,Time,EstVol,Yield);

elseif Type == 2
    [ AmeCallPrice,AmePutPrice,~,~,Prob] = CRRPrice(Price,Strike,Rate,Time,Volatility,Yield);
    if strcmp(Side,'buycall') || strcmp(Side,'sellcall')
        OurPrice = AmeCallPrice;
    elseif strcmp(Side,'buyput') || strcmp(Side,'sellput')
        OurPrice = AmePutPrice;
    end
    fprintf('���ǶԸ���ʽ��Ȩ�Ķ���Ϊ��%f��Prob = %f\n',OurPrice,Prob);
    
    [CallDelta,PutDelta,Gamma,CallTheta,PutTheta,Vega,CallRho,PutRho] ...
    = BS_GreekLetters(Price,Strike,Rate,Time,EstVol,Yield);


elseif Type == 3
    if strcmp(Side,'buycall') || strcmp(Side,'sellcall')
        [AsianPrice,Var,UP] = Asian_improve(Price,Strike,Rate,Time,Volatility,1);
    elseif strcmp(Side,'buyput') || strcmp(Side,'sellput')
        [AsianPrice,Var,UP] = Asian_improve(Price,Strike,Rate,Time,Volatility,0);
    end
    fprintf('���ǶԸ���ʽ��Ȩ�Ķ���Ϊ��%f\n',AsianPrice);
    fprintf('��ʽ��Ȩ�۸�ķ���Ϊ %f  0.95�����������Ȩ�۸����½�Ϊ[%f, %f]\n ',Var,UP);
    
   [CallDelta,PutDelta,Gamma,CallTheta,PutTheta,Vega,CallRho,PutRho] ...
   = AsianGreeksLevy(Price,Strike,EstVol,Rate,Settle,ExerciseDates);

elseif Type == 4
    [ BinCall,pCall,BinPut,pPut ] = BinPrice(Price,pCStrike,pPStrike,pCash,Rate,Volatility,Time,Yield);
    if strcmp(Side,'buycall') || strcmp(Side,'sellcall')
        OurPrice = BinCall;
        pS = pCall;
    elseif strcmp(Side,'buyput') || strcmp(Side,'sellput')
        OurPrice = BinPut;
        pS = pPut;
    end
    fprintf('���ǶԸö�Ԫ��Ȩ�Ķ���Ϊ��%f\n',OurPrice);
    fprintf('��Ȩ�۸�/��ļ۸� = %f\n',pS);
    
    [CallDelta,PutDelta,CallGamma,PutGamma,CallTheta,PutTheta,CallVega,PutVega,CallRho,PutRho] = ...
     Bin_GreekLetters( Price,pCStrike,pPStrike,Rate,pCash,EstVol,SettlePrice,ExerciseDates,Yield);
    
else
    msgbox('��Ȩ�����������');
end

if Type == 4 
    if strcmp(Side,'sellput') 
        fprintf('\nPutDelta: %f\n',-PutDelta);
        fprintf('PutGamma: %f\n',-PutGamma);
        fprintf('PutTheta: %f\n',-PutTheta);
        fprintf('PutVega: %f\n',-PutVega);
        fprintf('PutRho: %f\n',-PutRho);
    elseif strcmp(Side,'buycall') 
        fprintf('\nCallDelta: %f\n',CallDelta);
        fprintf('CallGamma: %f\n',CallGamma);
        fprintf('CallTheta: %f\n',CallTheta);
        fprintf('CallVega: %f\n',CallVega);
        fprintf('CallRho: %f\n',CallRho);
    elseif strcmp(Side,'buyput')
        fprintf('\nPutDelta: %f\n',PutDelta);
        fprintf('PutGamma: %f\n',PutGamma);
        fprintf('PutTheta: %f\n',PutTheta);
        fprintf('PutVega: %f\n',PutVega);
        fprintf('PutRho: %f\n',PutRho);
    elseif strcmp(Side,'sellcall')
        fprintf('\nCallDelta: %f\n',-CallDelta);
        fprintf('CallGamma: %f\n',-CallGamma);
        fprintf('CallTheta: %f\n',-CallTheta);
        fprintf('CallVega: %f\n',-CallVega);
        fprintf('CallRho: %f\n',-CallRho);
    else
        error('���׷����������');
    end
else 
    if strcmp(Side,'sellput') 
        fprintf('\nCallDelta: %f\n',abs(PutDelta));
        fprintf('Gamma: %f\n',-abs(Gamma));
        fprintf('CallTheta: %f\n',abs(PutTheta));
        fprintf('Vega: %f\n',-abs(Vega));
        fprintf('CallRho: %f\n',abs(PutRho));
    elseif strcmp(Side,'buycall') 
        fprintf('\nCallDelta: %f\n',abs(CallDelta));
        fprintf('Gamma: %f\n',abs(Gamma));
        fprintf('CallTheta: %f\n',-abs(CallTheta));
        fprintf('Vega: %f\n',abs(Vega));
        fprintf('CallRho: %f\n',abs(CallRho));
    elseif strcmp(Side,'buyput')
        fprintf('\nPutDelta: %f\n',-abs(PutDelta));
        fprintf('Gamma: %f\n',abs(Gamma));
        fprintf('PutTheta: %f\n',-abs(PutTheta));
        fprintf('Vega: %f\n',abs(Vega));
        fprintf('PutRho: %f\n',-abs(PutRho));
    elseif strcmp(Side,'sellcall')
        fprintf('\nPutDelta: %f\n',-abs(CallDelta));
        fprintf('Gamma: %f\n',-abs(Gamma));
        fprintf('PutTheta: %f\n',abs(CallTheta));
        fprintf('Vega: %f\n',-abs(Vega));
        fprintf('PutRho: %f\n',-abs(CallRho));
    else
        error('���׷����������');
    end
end