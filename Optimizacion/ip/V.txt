function [c,ceq] = V( F,vol )

N = max(size(F));

x = linspace(0,1,N);
deltaX = x(2) - x(1);
int = F.^2;
ceq = 0;
for j = 1:N-1
    ceq = ceq + deltaX * ( int(j) + int(j+1) )/2;
end
ceq = ceq - vol;
c = 0;
end

