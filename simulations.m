% Carregar redes ja treinadas:
if exist('trained_nets_1.mat', 'file') == 2
    load('trained_nets_1.mat')
else
    fprintf("Nenhuma rede salva.");
    return;
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
