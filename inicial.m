dados_petr3 = readtable("petr3.txt", "Delimiter", "\t");
dados_vale3 = readtable("vale3.txt", "Delimiter", "\t");
dados_embr3 = readtable("embr3.txt", "Delimiter", "\t");
close_price_petr3 = str2double(erase(dados_petr3.Open, '.')) / 1000000; %vetor de tamanho 1383,1
close_price_embr3 = str2double(erase(dados_embr3.Open, '.')) / 1000000 ; %vetor de tamanho 1383,1
close_price_viva3 = str2double(erase(dados_petr3.Open, '.')) / 1000000; %vetor de tamanho 1383,1

date_time = datetime(dados_petr3.Date, 'InputFormat', 'MM/dd/yyyy');

date_ref = datetime('01/02/2018', 'InputFormat','MM/dd/uuuu');
days_arr = 1:1383;
for i=1:1383
    days_arr(i) = days(date_time(i) - date_ref);
end
days_arr = days_arr';
days_arr = days_arr + 1; %vetor de tamanho 1383,1 que representa os dias de cada preço

% Parâmetros
delay = 9; 
train_days = 1293; 
test_days = 90;

% Separação dos dados de treinamento e teste
train_data_petr3 = close_price_petr3(1:train_days);
test_data_petr3 = close_price_petr3(train_days+1:end);

train_data_embr3 = close_price_embr3(1:train_days);
train_data_viva3 = close_price_viva3(1:train_days);

% Criar matrizes de atraso
trainMatrix_petr3 = zeros(delay+1, train_days-delay);
trainMatrix_embr3 = zeros(delay+1, train_days-delay);
trainMatrix_viva3 = zeros(delay+1, train_days-delay);
outputMatrix_petr3 = zeros(delay+1, train_days -delay);

for i = 1:(train_days - delay)
    trainMatrix_petr3(: , i) = train_data_petr3(i:i+delay);
    trainMatrix_viva3(: , i) = train_data_viva3(i:i+delay);
    trainMatrix_embr3(: , i) = train_data_embr3(i:i+delay);
    outputMatrix_petr3(:,i) = close_price_petr3(i+delay : i + 2*(delay));
end

% Concatenar para formar matrizes de entrada e saída
inputMatrix = [trainMatrix_petr3; trainMatrix_embr3; trainMatrix_viva3];

if exist('trained_network_1.mat', 'file') == 2
    load('trained_network_1.mat')
else
    net = feedforwardnet(15);
    net.layers{end}.size = 10;
    net = configure(net, inputMatrix, outputMatrix_petr3);
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 1.00;
    net.divideParam.valRatio = 0.00;
    net.divideParam.testRatio = 0.00;
    net = init(net);
    
    net.trainParam.showWindow = true;
    net.layers{1}.transferFcn = 'tansig';  % Função de ativação para a camada escondida
    net.layers{2}.transferFcn = 'purelin'; % Função de ativação para a camada de saída
    net.performFcn = 'mse';
    net.trainFcn = 'traincgp';
    net.trainParam.epochs = 1000;
    net.trainParam.time = 240;
    net.trainParam.min_grad = 10^-5;
    net.trainParam.max_fail = 50;
    [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
    
    save('trained_network_1.mat', 'net')
end

xPrecoPetr3 = close_price_petr3(1:1294);
plot(days_arr(1:1294), xPrecoPetr3, 'g');
hold on
train = net(inputMatrix);
plot(days_arr(1:1284), train(1, 1:1284), 'r');
xlabel('Dias')
ylabel('Preço')
grid

testMatrix_petr3 = zeros(delay+1, 90);
testMatrix_embr3 = zeros(delay+1, 90);
testMatrix_viva3 = zeros(delay+1, 90);

for i = 1:90
    testMatrix_petr3(: , i) = close_price_petr3(i + 1284: i + 1284 + delay);
    testMatrix_viva3(: , i) = close_price_viva3(i + 1284: i + 1284 + delay);
    testMatrix_embr3(: , i) = close_price_embr3(i + 1284: i + 1284 + delay);
end

inputTest = [testMatrix_petr3; testMatrix_viva3; testMatrix_embr3 ];
test = net(inputTest);
plot(days_arr(1296:1383), close_price_petr3(1296:1383), 'm');
plot(days_arr(1296:1383), test(1, 1:88), 'b');
legend('Série treinamento real', 'Treinamento', 'Série teste real', 'Previsão');

%Substititua algum desses codigo dentro else com base no modelo de rede que voce deseja

%Primeira rede
% net = feedforwardnet(15);
% net.layers{end}.size = 10;
% net = configure(net, inputMatrix, outputMatrix_petr3);
% net.divideFcn = 'dividerand';
% net.divideParam.trainRatio = 1.00;
% net.divideParam.valRatio = 0.00;
% net.divideParam.testRatio = 0.00;
% net = init(net);
% 
% net.trainParam.showWindow = true;
% net.layers{1}.transferFcn = 'tansig';  % Função de ativação para a camada escondida
% net.layers{2}.transferFcn = 'purelin';  % Função de ativação para a camada de saída
% net.performFcn = 'mse';
% net.trainFcn = 'trainlm';
% net.trainParam.epochs = 1000;
% net.trainParam.time = 240;
% net.trainParam.lr = 0.2;
% net.trainParam.min_grad = 10^-18;
% net.trainParam.max_fail = 1000;
% [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
% 
% save('trained_network_1.mat', 'net')

%Segunda rede
% net = feedforwardnet([10 10]);
% net.layers{end}.size = 10;
% net = configure(net, inputMatrix, outputMatrix_petr3);
% net.divideFcn = 'dividerand';
% net.divideParam.trainRatio = 1.00;
% net.divideParam.valRatio = 0.00;
% net.divideParam.testRatio = 0.00;
% net = init(net);
% 
% net.trainParam.showWindow = true;
% net.layers{1}.transferFcn = 'poslin';  % Função de ativação para a camada escondida
% net.layers{2}.transferFcn = 'poslin';  % Função de ativação para a camada de saída
% net.layers{3}.transferFcn = 'purelin';
% net.performFcn = 'mse';
% net.trainFcn = 'trainlm';
% net.trainParam.epochs = 1000;
% net.trainParam.time = 240;
% net.trainParam.lr = 0.01;
% net.trainParam.min_grad = 10^-18;
% net.trainParam.max_fail = 10000;
% [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
% 
% save('trained_network_1.mat', 'net')

%Terceira rede
% net = feedforwardnet(30);
% net.layers{end}.size = 10;
% net = configure(net, inputMatrix, outputMatrix_petr3);
% net.divideFcn = 'dividerand';
% net.divideParam.trainRatio = 1.00;
% net.divideParam.valRatio = 0.00;
% net.divideParam.testRatio = 0.00;
% net = init(net);
% 
% net.trainParam.showWindow = true;
% net.layers{1}.transferFcn = 'poslin';  % Função de ativação para a camada escondida
% net.layers{2}.transferFcn = 'purelin';  % Função de ativação para a camada de saída
% net.performFcn = 'mse';
% net.trainFcn = 'trainrp';
% net.trainParam.epochs = 100000;
% net.trainParam.time = 240;
% net.trainParam.lr = 0.1;
% net.trainParam.min_grad = 10^-18;
% net.trainParam.max_fail = 1000;
% [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
% 
% save('trained_network_1.mat', 'net')

%Quarta rede
% net = feedforwardnet(25);
% net.layers{end}.size = 10;
% net = configure(net, inputMatrix, outputMatrix_petr3);
% net.divideFcn = 'dividerand';
% net.divideParam.trainRatio = 1.00;
% net.divideParam.valRatio = 0.00;
% net.divideParam.testRatio = 0.00;
% net = init(net);
% 
% net.trainParam.showWindow = true;
% net.layers{1}.transferFcn = 'poslin';  % Função de ativação para a camada escondida
% net.layers{2}.transferFcn = 'purelin';  % Função de ativação para a camada de saída
% net.performFcn = 'mse';
% net.trainFcn = 'traincgp';
% net.trainParam.epochs = 100000;
% net.trainParam.time = 240;
% net.trainParam.lr = 0.05;
% net.trainParam.min_grad = 10^-18;
% net.trainParam.max_fail = 100000;
% [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
% 
% save('trained_network_1.mat', 'net')

%Quinta rede
% net = feedforwardnet([25 25]);
% net.layers{end}.size = 10;
% net = configure(net, inputMatrix, outputMatrix_petr3);
% net.divideFcn = 'dividerand';
% net.divideParam.trainRatio = 1.00;
% net.divideParam.valRatio = 0.00;
% net.divideParam.testRatio = 0.00;
% net = init(net);
% 
% net.trainParam.showWindow = true;
% net.layers{1}.transferFcn = 'tansig';  % Função de ativação para a camada escondida
% net.layers{2}.transferFcn = 'tansig';  % Função de ativação para a camada de saída
% net.layers{3}.transferFcn = 'purelin';
% net.performFcn = 'mse';
% net.trainFcn = 'trainbr';
% net.trainParam.epochs = 100000;
% net.trainParam.time = 240;
% net.trainParam.lr = 0.1;
% net.trainParam.min_grad = 10^-18;
% net.trainParam.max_fail = 100000;
% [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
% 
% save('trained_network_1.mat', 'net')

%Sexta rede
% net = feedforwardnet(15);
% net.layers{end}.size = 10;
% net = configure(net, inputMatrix, outputMatrix_petr3);
% net.divideFcn = 'dividerand';
% net.divideParam.trainRatio = 1.00;
% net.divideParam.valRatio = 0.00;
% net.divideParam.testRatio = 0.00;
% net = init(net);
% 
% net.trainParam.showWindow = true;
% net.layers{1}.transferFcn = 'tansig';  % Função de ativação para a camada escondida
% net.layers{2}.transferFcn = 'purelin'; % Função de ativação para a camada de saída
% net.performFcn = 'mse';
% net.trainFcn = 'traincgp';
% net.trainParam.epochs = 1000;
% net.trainParam.time = 240;
% net.trainParam.min_grad = 10^-5;
% net.trainParam.max_fail = 50;
% [net, tr] = train(net, inputMatrix, outputMatrix_petr3);
% 
% save('trained_network_1.mat', 'net')
