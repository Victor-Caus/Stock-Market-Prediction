% 1. Coleta de dados:
% Aqui deverá ser coletado os dados de entrada e saída do Excell

tablePETR = readtable('PETR3.xlsx');
tableVALE = readtable('VALE3.xlsx');
tableEMBR = readtable('EMBR3.xlsx');
close = cell(1, 3);
close{1} = tablePETR{:, 8};
close{2} = tableVALE{:, 8};
close{3} = tableEMBR{:, 8};

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
nSimulacao = 9; % (referente aos ultimos 3 meses 90/10)
indiceMaxTrein = nAmostras - nSimulacao;
% Separando os que vao ser treinados do total:
Ptr = P(:,1:indiceMaxTrein);
Ttr = cell(1, 3);
for i = 1:3
    Ttr{i} = T{i}(:,1:indiceMaxTrein);
end


% Carregar redes ja treinadas:
if exist('trained_nets_1.mat', 'file') == 2
    load('trained_nets_1.mat')
else
    fprintf("Nenhuma rede salva.");
    return;
end

% Plotar graficos de treinamento:
% Vamos preencher o P e o T simulando aos poucos:
close_trained = close;
for i = 1:3
    T_trained = sim(nets{i},Ptr);

    % "Desenpacotar as saidas em um array continuo como o close{i}"
    for j = 1 : nAmostras
        for k = 1 : 10
            close_trained{i}(10*(j-1) + k) = T_simu{i}(k,j);
        end
    end
end
%Grafico treino petrobras:
xInicio = 1:((nAmostras - nSimulacao)*10); 
figure(4)
plot(xInicio,close{1}(xInicio)','b')
xlabel('Dia')
ylabel('Cotacao da acao')
title('Fechamento da acao PETR3') 
grid
hold on
plot(xInicio,close_trained{1}(xInicio),':m');
hold off

%Grafico treino VALE:
figure(5)
plot(xInicio,close{2}(xInicio)','b')
xlabel('Dia')
ylabel('Cotacao da Acao')
title('Fechamento da acao VALE3') 
grid
hold on
plot(xInicio,close_trained{2}(xInicio),':m');
hold off

%Grafico treino EMBRAER:
xInicio = 1:((nAmostras - nSimulacao)*10); 
figure(6)
plot(xInicio,close{3}(xInicio)','b')
xlabel('Dia')
ylabel('Cotacao da acao')
title('Fechamento da acao EMBR3') 
grid
hold on
plot(xInicio,close_trained{3}(xInicio),':m');
hold off



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

% "Desenpacotar as saidas em um array continuo como o close{i}"
close_simu = cell(1,3);
for i = 1:3
    close_simu{i} = close{i}; %inicializar com tamanho certo para otimizar
end
for i = 1:3
    for j = 1 : nAmostras
        for k = 1 : 10
            close_simu{i}(10*(j-1) + k) = T_simu{i}(k,j);
        end
    end
end

% Plotar gráficos comparativos de cada ação
xInicio = 1:((nAmostras - nSimulacao)*10); 
xFinal = ((nAmostras - nSimulacao)*10)+1 : nAmostras*10;

% Ações da Petrobras (1)
figure(1)
plot(xInicio,close{1}(xInicio)','b',xFinal,close{1}(xFinal)','r')
xlabel('Dia')
ylabel('Cotação da ação')
title('Fechamento da ação PETR3') 
grid
hold on
plot(xInicio,close_simu{1}(xInicio),':m', xFinal,close_simu{1}(xFinal),':m');
hold off

% Vale do rio doce (2)
figure(2)
plot(xInicio,close{2}(xInicio)','b',xFinal,close{2}(xFinal)','r')
xlabel('Dia')
ylabel('Cotação da ação')
title('Fechamento da ação VALE3') 
grid
hold on
plot(xInicio,close_simu{2}(xInicio),':m', xFinal,close_simu{2}(xFinal),':m');
hold off

% Embraer (3)
figure(3)
plot(xInicio,close{3}(xInicio)','b',xFinal,close{3}(xFinal)','r')
xlabel('Dia')
ylabel('Cotação da ação')
title('Fechamento da ação EMBR3') 
grid
hold on
plot(xInicio,close_simu{3}(xInicio),':m', xFinal,close_simu{3}(xFinal),':m');
hold off
