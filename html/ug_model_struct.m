%% Define the model structure
% Now the model should be written in a Yaml file, however Matlab does not know
% anything about the Yaml file and even if it did, such a file is easy to read
% and write for human, but does not mean anything for Matlab. So we have to tell
% Matlab to use the Yaml file and to convert it to a format suitable for
% Matlab. We have also to provide additional information about the structure of
% shocks.

%% Convert the Yaml file and create the model structure
% This task is done by the function |recsmodelinit| that calls a Python
% preprocessor, to convert the model described in a Yaml file to a file readable
% by MATLAB and RECS programs. In the conversion, it calculates the analytic
% representation of all partial derivatives.
% 
% A simple call to |recsmodelinit| takes the following form:
%
%  model = recsmodelinit('file.yaml');
%
% This call does two things:
%
% * It converts |file.yaml| to |filemodel.m|, which contains the model
% definition in a Matlab readable form but also all the derivatives of the
% equations, plus some additional information such as the parameters values for
% calibration or a first guess for the steady state.
% * It creates in Matlab workspace the structure |model| with two fields: the
% function name, |func| equal to |@filemodel|, and the parameters values,
% |params|, if these latter have been provided in the Yaml file.

%% Shocks with a Gaussian distribution
% If your shocks follow a Gaussian distribution, you can also define their
% structure when calling |recsmodelinit|. I requires to define a structure with
% 3 fields characterizing the distribution mean, variance/covariance, and order
% of approximation, with the call
%
%  model = recsmodelinit('file.yaml',...
%                        struct('Mu',Mu,'Sigma',Sigma,'order',order));
%
% Here |Mu| is a size-q vector of the distribution mean; |Sigma| is a q-by-q
% positive definite variance/covariance matrix; and |order| is a scalar or a
% size-q vector equal to the number of nodes for each shock variable.
% 
% This function call creates at least 3 additional fields in the model
% structure: |e| a matrix of the nodes for the shocks discretization; |w| the
% vector of associated probabilities; and |funrand| an anonymous function that
% can generate random numbers corresponding to the underlying distribution.
%
% If a first-guess for the deterministic steady state has been provided,
% |recsmodelinit| attempts also to find the deterministic steady state of the
% problem. If it finds it, it is displayed on screen and output as 3 fields in
% the model structure: |sss|, |xss|, and |zss| for, respectively, the
% steady-state values of state, response and expectations variables.

%% An example
% Let's consider the example of the stochastic growth model. The complete
% function call in <gro1.html gro1.m> is:
model = recsmodelinit('gro1.yaml',...
                      struct('Mu',0,'Sigma',0.007^2,'order',5));
%% 
% The model structure has the following fields:
disp(model)

%% Notes on functions used
% The shock discretization is done with the function |qnwnorm| from the CompEcon
% toolbox. The random number generation is simply done with the Matlab |randn|
% function.