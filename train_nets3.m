% 1. Coleta de dados:
% Aqui deverá ser coletado os dados de entrada e saída do Excell
P = []; %sera uma matriz onde P(1,:) é da PETR, P(2,:) é da VALE, P(3,:) é da EMBR. 
T = []; % Tambem uma matriz seguindo a mesma ordem

% OBS: A arquitetura dessa rede foi inventada pelo grupo
% 2.Construção das Redes de arquitetura MLP, seguindo a ordem convencionada
nets = cell(1, 3); % vetor contendo as respectivas redes neurais
for i = 1:3
    nets(i) = feedforwardnet({15,10}); % 2 camadas internas
    nets(i) = configure(nets(i),P(i),T(i));
end

% 3. Pré-processamento dos Dados
% 3.1) Normalizar os padrões de Treinamento de entrada/saída entre 0 e 1:
for i = 1:3
    for j = 1:size(P(i))
    nets(i).inputs{j}.processParams{2}.ymin = 0;
    nets(i).inputs{j}.processParams{2}.ymax = 1;
    end
end

% 3.2) Dividir os dados entre os conjuntos de Treino, Validação e Erro de
% Teste:
for i = 1:3
    nets(i).divideFcn = 'dividerand';
    nets(i).divideParam.trainRatio = 1.00;
    nets(i).divideParam.valRatio = 0.00;
    nets(i).divideParam.testRatio = 0.00;
end

% 4. Treinamento das redes
for i = 1:3
    nets(i).trainParam.showWindow = true;   % Exibe a interface de usuário (GUI)
    % Arquitetura da rede e funções de ativação de cada camada:
    nets(i).layers{1}.dimensions = 15;
    nets(i).layers{1}.transferFcn = 'relu';
    nets(i).layers{2}.dimensions = 10;
    nets(i).layers{2}.transferFcn = 'relu';
    nets(i).layers{3}.transferFc = 'purelin';  % Output como puramente linear
    nets(i).performFcn = 'mse';         % Usamos somas quadráticas 
    nets(i).trainFcn = 'trainrp';       % Algoritmo de otimização usado

    % Hiperparametros de treinamentos (Ajustar "na mão"):
    nets(i).trainParam.epochs = 10000;
    nets(i).trainParam.time = 120;
    nets(i).trainParam.lr = 0.2;
    nets(i).trainParam.min_grad = 10^-8;
    nets(i).trainParam.max_fail = 1000;

    [net,tr] = train(net,P(i),T(i));
end

%5. Teste das redes neurais:
% Ainda a fazer
