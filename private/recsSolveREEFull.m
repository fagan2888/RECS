function [c,x,f,exitflag] = recsSolveREEFull(interp,model,s,x,c,options)
% RECSSOLVEREEFULL finds the REE of a model as one single problem and not by iterating on two subproblems
%
% RECSSOLVEREEFULL is called by RECSSOLVEREE. It is not meant to be called directly
% by the user.
%
% See also RECSSOLVEEREE, RECSSOLVEEREEITER.
  
% Copyright (C) 2011 Christophe Gouel
% Licensed under the Expat license, see LICENSE.txt

%% Initialization
eqsolver         = lower(options.eqsolver);
eqsolveroptions  = options.eqsolveroptions;
extrapolate      = options.extrapolate;
funapprox        = lower(options.funapprox);
functional       = options.functional;

e      = model.e;
func   = model.func;
params = model.params;
w      = model.w;

fspace = interp.fspace;
Phi    = interp.Phi;

[n,m]  = size(x);

[~,grid] = spblkdiag(zeros(m,m,n),[],0);
X        = [reshape(x',[n*m 1]); reshape(c',[],1)];
[LB,UB]  = func('b',s,[],[],[],[],[],params);
LB       = [reshape(LB',[n*m 1]); -inf(n*size(c,2),1)];
UB       = [reshape(UB',[n*m 1]); +inf(n*size(c,2),1)];

% $$$ [f,J] = recsFullPb(X,s,func,params,grid,e,w,fspace,funapprox,Phi,m,functional,extrapolate);
% $$$ Jnum = numjac(@(VAR) recsFullPb(VAR,s,func,params,grid,e,w,fspace,funapprox,Phi,m,functional,extrapolate),X);
% $$$ spy(J)
% $$$ figure
% $$$ spy(Jnum)
% $$$ norm(full(J)-Jnum)
% $$$ norm(full(J(1:n*m,n*m+1:n*(m+size(c,2))))-Jnum(1:n*m,n*m+1:n*(m+size(c,2))))
% $$$ norm(full(J(n*m+1:n*(m+size(c,2)),n*m+1:n*(m+size(c,2))))-Jnum(n*m+1:n*(m+size(c,2)),n*m+1:n*(m+size(c,2))))
% $$$ z = [];
% $$$ return

%% Solve for the rational expectations equilibrium
[X,f,exitflag] = runeqsolver(@recsFullPb,X,LB,UB,eqsolver,eqsolveroptions,...
                             s,func,params,grid,e,w,fspace,funapprox,Phi,...
                             m,functional,extrapolate);

%% Reshape outputs 
x     = reshape(X(1:n*m),m,n)';
c     = reshape(X(n*m+1:end),[],n)';
