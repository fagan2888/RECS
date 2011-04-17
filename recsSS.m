function [s,x,z] = recsSS(model,s,x,options)
% RECSSS Solves for the deterministic steady state in rational expectations models
%
% S = RECSSS(MODEL,S,X)
%
% S = RECSSS(MODEL,S,X,OPTIONS)  solves the problem with the parameters
% defined by the structure OPTIONS. The fields of the structure are
%    eqsolver         : 'fsolve', 'lmmcp' (default), 'ncpsolve' or 'path'
%    eqsolveroptions  : options structure to be passed to eqsolver
%    functional       : 1 if the equilibrium equations are a functional equation
%                       problem (default: 0)
%
% [S,X] = RECSSS(MODEL,S,X,...)
%
% [S,X,Z] = RECSSS(MODEL,S,X,...)

% Copyright (C) 2011 Christophe Gouel
% Licensed under the Expat license, see LICENSE.txt

if nargin<4, options = struct([]); end

defaultopt = struct(...
    'eqsolver'        , 'lmmcp',...
    'eqsolveroptions' , struct([]),...
    'functional'      , 0);
warning('off','catstruct:DuplicatesFound')

options = catstruct(defaultopt,options);

if options.functional
  error(['This program cannot solve for the deterministic steady state of a ' ...
         'functional equation problem']);
end
eqsolver        = options.eqsolver;
eqsolveroptions = options.eqsolveroptions;

params = model.params;
e      = model.w'*model.e;
d      = length(s);
m      = length(x);
if isa(model.func,'char')
  func = str2func(model.func);
elseif isa(model.func,'function_handle')
  func   = model.func;
else
  error('model.func must be either a string or a function handle')
end

exitflag = 1;

X       = [s(:); x(:)];
[LB,UB] = func('b',s,[],[],[],[],[],params);
LB      = [-inf(size(s(:))); LB(:)];
UB      = [+inf(size(s(:))); UB(:)];

switch lower(eqsolver)
 case 'fsolve'
  opt = optimset('Display','off',...
                 'Jacobian','on');
  opt = optimset(opt,eqsolveroptions);
  [X,~,exitflag] = fsolve(@(Y) SSResidual(Y,func,params,e,d,m),...
                          X,...
                          opt);
 case 'lmmcp'
  [X,~,exitflag] = lmmcp(@(Y) SSResidual(Y,func,params,e,d,m),...
                         X,...
                         LB,...
                         UB,...
                         eqsolveroptions);
 case 'ncpsolve'
  X = ncpsolve(@ncpsolvetransform,...
               LB,...
               UB,...
               X,...
               @SSResidual,...
               func,params,e,d,m);
 case 'path'
  global par
  par = {@SSResidual,func,params,e,d,m};
  X   = pathmcp(X,LB,UB,'pathtransform');
  clear global par
end

if exitflag~=1, disp('Failure to find a deterministic steady state'); end

s      = X(1:d)';
x      = X(d+1:d+m)';
output = struct('F',1,'Js',0,'Jx',0,'Jsn',0,'Jxn',0,'hmult',0);
z      = func('h',s,x,[],e,s,x,params,output);


%%%%%%%%%%%%%%%%
% Subfunctions %
%%%%%%%%%%%%%%%%
function [F,J] = SSResidual(X,func,params,e,d,m)

if nargout==2
  J = sparse(numjac(@residual_function,X,[],func,params,e,d,m));
end
F   = residual_function(X,func,params,e,d,m);

function F = residual_function(X,func,params,e,d,m)
ss     = X(1:d)';
xx     = X(d+1:d+m)';
output = struct('F',1,'Js',0,'Jx',0,'Jz',0,'Jsn',0,'Jxn',0,'hmult',0);
zz     = func('h',ss,xx,[],e ,ss,xx,params,output);
g      = func('g',ss,xx,[],e ,[],[],params,output);
f      = func('f',ss,xx,zz,[],[],[],params,output);
F      = [ss-g f]';
return
