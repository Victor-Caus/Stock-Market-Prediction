% 1. Coleta de dados:
% Aqui deverá ser coletado os dados de entrada e saída do Excell


tablePETR = readtable('PETR3.xlsx');
tableVALE = readtable('VALE3.xlsx');
tableEMBR = readtable('EMBR3.xlsx');
close = cell(1, 3);
close{1} = tablePETR{:, 7};
close{2} = tableVALE{:, 7};
close{3} = tableEMBR{:, 7};


T = cell(1, 3); % sera uma celula de matrizes onde T{1} é da PETR, T{2} é da VALE, T{3} é da EMBR. 
nAmostras = floor(size(close{1},1)/10) - 1;
P = zeros(30, nAmostras); % padrões de entrada

% organizando as amostras
for i = 1:nAmostras
    % pegar os fechamentos "atrasados" das três:
    P(:,i) = [close{1}(10*i - 9 : 10*i) ; close{2}(10*i - 9 : 10*i) ; close{3}(10*i - 9 : 10*i)];
    
    % para cada uma, pegar a saída como sendo os fechamentos adiantados:
    for j = 1:3
        T{j}(:,i) = [close{j}(10*(i+1) - 9 : 10*(i+1))];
    end
end

%Variáveis importantes:
nSimulacao = 90; % (referente aos ultimos 3 meses)
indiceMaxTrein = nAmostras - nSimulacao;
% Separando os que vao ser treinados do total:
Ptr = P(:,1:indiceMaxTrein);
Ttr = cell(1, 3);
for i = 1:3
    Ttr{i} = T{i}(:,1:indiceMaxTrein);
end

% 2.Construção das Redes de arquitetura MLP, seguindo a ordem convencionada
nets = cell(1, 3); % vetor contendo as respectivas redes neurais
for i = 1:3
    nets{i} = feedforwardnet(15); % 1 camada internas
    nets{i} = configure(nets{i},Ptr,Ttr{i});
end

% 3. Pré-processamento dos Dados
% 3.1) Normalizar os padrões de Treinamento de entrada/saída entre 0 e 1:
for i = 1:3
    for j = 1:size(P(i))
    nets{i}.inputs{j}.processParams{2}.ymin = 0;
    nets{i}.inputs{j}.processParams{2}.ymax = 1;
    end
end

% 3.2) Dividir os dados entre os conjuntos de Treino, Validação e Erro de
% Teste:

for i = 1:3
    nets{i}.divideFcn = 'dividerand';
    nets{i}.divideParam.trainRatio = 1.00;
    nets{i}.divideParam.valRatio = 0.00;
    nets{i}.divideParam.testRatio = 0.00;
end

% 4. Treinamento das redes
for i = 1:3
    nets{i}.trainParam.showWindow = true;   % Exibe a interface de usuário (GUI)
    % Arquitetura da rede e funções de ativação de cada camada:
    nets{i}.layers{1}.dimensions = 15;
    nets{i}.layers{1}.transferFcn = 'tansig';
    nets{i}.layers{2}.transferFcn = 'purelin';  % Output como puramente linear
    nets{i}.performFcn = 'mse';         % Usamos somas quadráticas 
    nets{i}.trainFcn = 'trainlm';       % Algoritmo de otimização usado

    % Hiperparâmetros de treinamentos (Ajustar "na mão"):
    nets{i}.trainParam.epochs = 10000;
    nets{i}.trainParam.time = 120;
    nets{i}.trainParam.lr = 0.2;
    nets{i}.trainParam.min_grad = 10^-22; % O ideal seria 10^-20
    nets{i}.trainParam.max_fail = 1000;

    [nets{i},tr] = train(nets{i},Ptr,Ttr{i});
end

%5. Simulacao das redes neurais:
% Vamos preencher o P e o T simulando aos poucos:
P_simu = P; 
T_simu = T;

for j = 1 : nAmostras
    for i = 1:3
        T_simu{i}(:,j) = sim(nets{i}, P_simu(:,j));
    end
    % "As saídas serão as entradas - Mateus 20:16":
    P_simu(:,j+1) = [T_simu{1}(:,j) ; T_simu{2}(:,j) ; T_simu{3}(:,j)];
end



