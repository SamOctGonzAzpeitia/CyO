%% Función Área
%Defino el área a optimizar
%Voy a definir una función A en función de F
%Esta F la especifico luego en el programa donde la optimice
%Diferencias finitas+Regla del trapecio

function Area = Area(F)
%Area = integral (F(1+(dF/dx)^2)^1/2 dz)
%Tengo que resolverla numéricamente
%N número de puntos
N=length(F);
%F es función de x defino los puntos donde evalúo F
%Con la funcion linspace hago un equiespaciado de 0 a N de 1 en 1
x=linspace(0,1,N);
deltax=x(2)-x(1);
%Equiespaciado, así que no va a cambiar
%Ahora toca calcular la derivada de F dF/dX
%Usando los conocimientos arcanos de Cálculo Numérico
dF = zeros(1,N);
for j=2:length(F)-1
dF(j)= (F(j+1)-F(j-1))/(deltax*2);
end
%Lo hemos hecho de 2 a N-1, necesito ponerlo en el 1 y el final, end
dF(1)=(-F(3)+4*F(2)-3*F(1))/(deltax*2);
dF(end)=(F(end-2)-4*F(end-1)+3*F(end))/(deltax*2);
%Defino la intergal para calcular el Area
inte = F.*sqrt(1+(dF).^2);
%Usamos la regla del trapecio para hacer la integral y calcular Area
% Area=(b-a)*((f(a)-f(b))/2)
Area=0;
for j = 1:N-1
   Area = Area + (x(j+1) - x(j)) * (inte(j)+inte(j+1))/2;
end
end


