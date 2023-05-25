

function Area = Area(F)
N=length(F);
x=linspace(0,1,N);
deltax=x(2)-x(1);
dF = zeros(1,N);
for j=2:length(F)-1
dF(j)= (F(j+1)-F(j-1))/(deltax*2);
end
dF(1)=(-F(3)+4*F(2)-3*F(1))/(deltax*2);
dF(end)=(F(end-2)-4*F(end-1)+3*F(end))/(deltax*2);
inte = F.*sqrt(1+(dF).^2);
Area=0;
for j = 1:N-1
   Area = Area + (x(j+1) - x(j)) * (inte(j)+inte(j+1))/2;
end
end


