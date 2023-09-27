clear all
clc


% 1) Criar Padrões de Entrada/Saida
% Datas dos dados: 15/10/2017 à 15/10/2021(antes da pandemia)

petr = readmatrix('PETR4.SA.csv'); % Na tabela 992 x 7, close na coluna 6
vale = readmatrix('VALE3.SA.csv'); % Na tabela 992 x 7, close na coluna 6
embr = readmatrix('EMBR3.SA.csv'); % Na tabela 992 x 7, close na coluna 6

petr = petr(:, 5);
vale = vale(:, 5);
embr = embr(:, 5);

% usaremos para treinamento 3 anos e 9 meses ~~ 930 dias,
% e para teste, 3 meses ~~ 60 dias
% Dividindo em treino e previsão
Ppetr = zeros(30, 93);
Tpetr = zeros(10, 93);
Pvale = zeros(30, 93);
Tvale = zeros(10, 93);
Pembr = zeros(30, 93);
Tembr = zeros(10, 93);

for i = 0:1:92

    colunaPetr = [petr(10 * i + 1:10 * i + 10)' vale(10 * i + 1:10 * i + 10)' embr(10 * i + 1:10 * i + 10)']';
    colunaVale = [petr(10 * i + 1:10 * i + 10)' vale(10 * i + 1:10 * i + 10)' embr(10 * i + 1:10 * i + 10)']';
    colunaEmbr = [petr(10 * i + 1:10 * i + 10)' vale(10 * i + 1:10 * i + 10)' embr(10 * i + 1:10 * i + 10)']';
    %colunaVale = [vale(10 * i + 1:10 * i + 10)' embr(10 * i + 1:10 * i + 10)' petr(10 * i + 1:10 * i + 10)']';
    %colunaEmbr = [embr(10 * i + 1:10 * i + 10)' petr(10 * i + 1:10 * i + 10)' vale(10 * i + 1:10 * i + 10)']';

    Ppetr(:, i + 1) = colunaPetr;
    Tpetr(:, i + 1) = petr(10 * (i + 1) + 1:10 * (i + 1) + 10);

    Pvale(:, i + 1) = colunaVale;
    Tvale(:, i + 1) = vale(10 * (i + 1) + 1:10 * (i + 1) + 10);

    Pembr(:, i + 1) = colunaEmbr;
    Tembr(:, i + 1) = embr(10 * (i + 1) + 1:10 * (i + 1) + 10);
end

P = cell(3, 1);
P{1} = Ppetr;
P{2} = Pvale;
P{3} = Pembr;

T = cell(3, 1);
T{1} = Tpetr;
T{2} = Tvale;
T{3} = Tembr;


% 2) Criar uma arquitetura de rede MLP para cada rede

% netPetr = feedforwardnet(20);
% netPetr = configure(netPetr,Ppetr,Tpetr);
% netVale = feedforwardnet(20);
% netVale = configure(netVale,Pvale,Tvale);
% netEmbr = feedforwardnet(20);
% netEmbr = configure(netEmbr,Pvale,Tvale);

% netVector = [netPetr netVale netEmbr];

% FASE 3 - Pré-processamento dos dados

% 3.1 - Normaliza os padrões de treinamento de entrada e saída entre 0 e 1
% para as três redes

netVector = cell(3, 1);

for i = 1:3
    netVector{i} = feedforwardnet([15,15]);
    netVector{i} = configure(netVector{i}, P{i}, T{i});
    netVector{i}.inputs{1}.processParams{2}.ymin = 0;
    netVector{i}.inputs{1}.processParams{2}.ymax = 1;

    netVector{i}.outputs{2}.processParams{2}.ymin = 0;
    netVector{i}.outputs{2}.processParams{2}.ymax = 1;
end

% 3.2 - Dividindo os dados em três subconjuntos distintos: treinamento,
% validação e erro de teste, para as três redes

for i = 1:3
    netVector{i}.divideFcn = 'dividerand';
    netVector{i}.divideParam.trainRatio = 1.00;
    netVector{i}.divideParam.valRatio = 0.00;
    netVector{i}.divideParam.testRatio = 0.00;
end

% 4) Inicializando os Pesos de cada uma das três Redes
for i = 1:3
    netVector{i} = init(netVector{i});
end

trVector = cell(3,1);
% 5 - Treinando a rede neural
for i = 1:3
    netVector{i}.trainParam.showWindow = true;
    netVector{i}.layers{1}.dimensions = 15; % número de neurônios da camada interna 1
    netVector{i}.layers{2}.dimensions = 15; % número de neurônios da camada interna 2
    netVector{i}.layers{1}.transferFcn = 'tansig'; % função de entrada na camada interna
    netVector{i}.layers{2}.transferFcn = 'tansig'; % função de entrada na camada interna
    netVector{i}.layers{3}.transferFcn = 'purelin'; % função de saída da camada interna
    netVector{i}.performFcn = 'mse'; % função que avalia a performance - mean squared

    %netVector(i).trainFcn = 'trainrp'; % algoritmo de treinamento Resilient Backpropagation
    %netVector(i).trainFcn = 'trainbr'; % algoritmo de treinamento Bayesian Regularization
    netVector{i}.trainFcn = 'trainrp'; % algoritmo de treinamento Levemberg-Marquadat

    netVector{i}.trainParam.epochs = 10^5; % número máximo de épocas de treinamento
    netVector{i}.trainParam.time = 480; % tempo máximo de treinamento
    netVector{i}.trainParam.lr = 0.20; % taxa de aprendizado
    netVector{i}.trainParam.mu = 0.9; 
    netVector{i}.trainParam.min_grad = 10^-10; % valor mínimo do gradiente, como critério de parada
    netVector{i}.trainParam.max_fail = 10^5; % número máximo de interações sem decaimento

    [netVector{i}, tr] = train(netVector{i}, P{i}, T{i});
    trVector{i} = tr;
end


% 6) Simular as respostas de salda da rede MLP


% 6.1) Obter Resultados da Simulação para as três ações
xSimulacao=1:1:(99*10);
valoresIniciais = [petr(1:10) vale(1:10) embr(1:10)];

% valorDePrevisao = [petr(1:10)' vale(1:10)' embr(1:10)']';
% 
% yPrevisao = cell(1, 3);
% yPrevisao{1} = petr(1:10)';
% yPrevisao{2} = vale(1:10)';
% yPrevisao{3} = embr(1:10)';


valorDePrevisao = [petr(921:930)' vale(921:930)' embr(921:930)']';

yPrevisao = cell(1, 3);
yPrevisao{1} = petr(921:930)';
yPrevisao{2} = vale(921:930)';
yPrevisao{3} = embr(921:930)';

valorPrevisto = cell(1, 3);
% for j=1:1:98
for j = 94:98
   for i = 1:3
       valorPrevisto{i} = sim(netVector{i},valorDePrevisao);
       yPrevisao{i} = [yPrevisao{i} valorPrevisto{i}'];
   end
   valorDePrevisao = [valorPrevisto{1}' valorPrevisto{2}' valorPrevisto{3}']';
end

% 6.1) Plotar Padrões de Treinamento de cada ação
xInicio = 1:1:(93*10); 
xFinal = (93*10)+1:1:99*10;

% Petrobrás
figure(1)
yPetrInicio = petr(1:93*10)';
yPetrFinal = petr(93*10+1:99*10)';
plot(xInicio,yPetrInicio,'b',xFinal,yPetrFinal,'r')
xlabel('Dia')
ylabel('Preço da ação')
title('Fechamento da ação PETR4') 
grid
hold on
% plot(xSimulacao,yPrevisao{1},':m');
plot(xFinal,yPrevisao{1},':m');
hold off

% Vale do rio doce
figure(2)
yValeInicio = vale(1:93*10)';
yValeFinal = vale(93*10+1:99*10)';
plot(xInicio,yValeInicio,'b',xFinal,yValeFinal,'r')
xlabel('Dia')
ylabel('Preço da ação')
title('Fechamento da ação VALE3') 
grid
hold on
% plot(xSimulacao,yPrevisao{2},':m');
plot(xFinal,yPrevisao{2},':m');
hold off

% Embraer 
figure(3)
yEmbrInicio = embr(1:93*10)';
yEmbrFinal = embr(93*10+1:99*10)';
plot(xInicio,yEmbrInicio,'b',xFinal,yEmbrFinal,'r')
xlabel('Dia')
ylabel('Preço da ação')
title('Fechamento da ação EMBR3') 
grid
hold on
% plot(xSimulacao,yPrevisao{3},':m');
plot(xFinal,yPrevisao{3},':m');
hold off

