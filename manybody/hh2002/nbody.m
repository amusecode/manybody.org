%The first function initialises, runs at intervals of length {\tt dt}
%(collecting data in {\tt y}), and outputs a final result.
%{\tt\obeylines

function nbody(n,nout,tmax)
cpu = cputime;dt=tmax/nout;t=0;
[h,x,xdot,f,fdot,step,tlast,m,y] = initialise(n);
nsteps=0;
while t<tmax
   [x,xdot,f,fdot,step,tlast,m,t,nsteps] = ...
      hermite(x,xdot,f,fdot,step,tlast,m,t,t+dt,nsteps);
   [y]=runtime_output(h,x,y,t,n);
end
final_output(t,cpu,nsteps,y)

  %}\medskip

%This function initialises various scalars, chooses {\tt n} positions
%and velocities with a uniform distribution inside spheres whose radii
%are chosen to give $N$-body units approximately.  It then sets masses,
%and times when particles were most recently updated (i.e. $0$,
%initially).  Forces, force derivatives and initial timesteps are
%selected (cf. Makino \& Aarseth 1992).  Finally a plot window for
%showing a movie is initialised. 
%{\tt\obeylines

function [h,x,xdot,f,fdot,step,tlast,m,y] = ...
initialise(n)
    y(1)=0;figure(1)
x = uniform(n,6/5);
xdot = uniform(n,sqrt(5/6));
m = ones(1,n)./n;
tlast = zeros(1,n);
for i = 1:n
	[f(1:3,i),fdot(1:3,i)] = ffdot(x,xdot,m,i);
	step(i) = 0.01*sqrt(sum(f(1:3,i).^2)/sum(fdot(1:3,i).^2));
end
h=plot(x(1,:),x(2,:),'o');
axis([-2 2 -2 2])
axis square
grid off
set(h,'EraseMode','xor','MarkerSize',2)
%\medskip
function [x] = uniform(n,a)
	r = a*rand(1,n).^(1/3);
	cos_theta = 2*rand(1,n)-1;
	sin_theta = sqrt(1-cos_theta.^2);
	phi = 2*pi*rand(1,n);
	x(1,1:n) = r.*sin_theta.*cos(phi);
	x(2,1:n) = r.*sin_theta.*sin(phi);
	x(3,1:n) = r.*cos_theta;
%}\medskip

%Particles are updated in this function.  In the main loop, the next
%particle for updating is found ({\tt i}), positions and velocities of all
%particles are predicted, and force and force derivative on {\tt i} are
%computed by a call to {\tt ffdot} (see below).  Higher order Hermite corrections {\tt a2} and {\tt a3} are
%computed and the corrections applied.  Finally the next time step is
%estimated and some variables are updated.
%{\tt\obeylines

function [x,xdot,f,fdot,step,tlast,m,t,nsteps] = ...
hermite	(x, xdot, f, fdot, step, tlast, m, t, tend,nsteps)
	n = size(m,2);
	while t < tend
		[t,i] = min(step + tlast);
		dt = t - tlast;
		dts = dt.^2;
		dtc = dts.*dt;
		dt3 = dt(ones(1,3),:);
		dts3 = dts(ones(1,3),:);
		dtc3 = dtc(ones(1,3),:);
		xtemp = x + xdot.*dt3 + f.*dts3/2 + fdot.*dtc3/6;
		xdottemp = xdot + f.*dt3 + fdot.*dts3/2;
		[fi,fidot] = ffdot(xtemp,xdottemp,m,i);
		a2 = (-6*(f(1:3,i) - fi) - step(i)*(4*fdot(1:3,i) + ...
2*fidot))/step(i)^2;
		a3 = (12*(f(1:3,i) - fi) + 6*step(i)*(fdot(1:3,i) + ...
fidot))/step(i)^3;
		x(1:3,i) = xtemp(1:3,i) + step(i)^4*a2/24 + ...
step(i)^5*a3/120;
		xdot(1:3,i) = xdottemp(1:3,i) + step(i)^3*a2/6 + ...
step(i)^4*a3/24;
		f(1:3,i) = fi;
		fdot(1:3,i) = fidot;
		modfi = sum(fi.^2);
		modfidot = sum(fidot.^2);
		moda2 = sum(a2.^2);
		moda3 = sum(a3.^2);
		step(i) = min(1.2*step(i),sqrt(0.02*(sqrt(modfi*moda2) ...
+ modfidot)/(sqrt(modfidot*moda3) + moda2)));
		tlast(i) = t;
		nsteps = nsteps + 1;
	end

%\medskip
function [fi,fidot] = ffdot(x,xdot,m,i)
n = size(m,2);
j = [1:i-1,i+1:n];
rij = x(:,i)*ones(1,n-1) - x(:,j);
rijdot = xdot(:,i)*ones(1,n-1) - xdot(:,j);
r2 = sum(rij.^2);
rrdot = sum(rij.*rijdot);
r3 = r2.^1.5;
r5 = r3.*r2;
fi = - rij*(m(j)./r3)';
fidot = - rijdot*(m(j)./r3)' + 3*rij*(rrdot.*m(j)./r5)';
%}\medskip

%This customisable function updates the movie and collects data for plotting the rms distance
%of all particles
%against time.
%{\tt\obeylines

function [y]=runtime_output(h,x,y,t,n)
set(h,'XData',x(1,:),'YData',x(2,:));
drawnow
m = size(y,1);
y(m+1,1) = sqrt(sum(sum(x(:,:).^2)))/n;
y(m+1,2) = t;
%\medskip
function final_output(t,cpu,nsteps,y)
t
tcpu=cputime-cpu
nsteps
figure(2)
plot(y(2:end,2),y(2:end,1),'-')
%}\medskip
