function A = A_compacto(F)

N = length(F);

x = linspace(0,1,N);
deltaX = x(2) - x(1);

y = zeros(1,N-1);
for i = 1:N-1
    y(i) = ( F(i) + F(i+1) )/2;
end

dy = zeros(1,N-1);
for i = 1:N-1
    dy(i) = ( F(i+1) - F(i) )/deltaX;
end

int = y.*sqrt(1+(dy).^2);
A = 0;
for i = 1:N-1
   A = A + deltaX * int(i) ;
end


end