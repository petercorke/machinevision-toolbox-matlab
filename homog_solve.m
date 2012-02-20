%HOMOG_SOLVE various linear equation solvers used by fmatrix and homography
%



% Copyright (C) 1993-2011, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for Matlab (MVTB).
% 
% MVTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% MVTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with MVTB.  If not, see <http://www.gnu.org/licenses/>.

function x = homog_solve(how, A, b)

	switch how,
	case 'eigsol',
		x = eigsol(A);
	case 'lsqsvd',
		x = lsqsvd(A, b);
	case 'psinvsol',
		x = psinvsol(A,b);
	case 'psinvsvd',
		x = psinvsvd(A,b);
	otherwise,
		error('bad method');
	end

function x = eigsol(A);

% EIGSOL Calculate the eigen value solution of the system Ax=0.
% x = eigsol(A);
%
% input  : Coeficient Matrix of the system, A
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=1),
  error('Requires one input argument.');
else
  if (isstr(A)),
    error('Requires one matrix as input arguments.');
  else
    [V D]=eig(A'*A);
    m=1.0e+308;
    j=1;
    for i=1:size(D,1),
      if (m>D(i,i)),
	m=D(i,i);
	j=i;
      end;
    end;
    x=V(:,j);
  end;	
end;

function  x = lsqsvd(A,b);

% LSQSVD Computes the least-squares solution x of the system Ax=b,
%   using the SVD of A.
% x = lsqsvd(A,b);
%
% input  : Coeficient Matrix of the system, A
%			  Result vector of the system, b
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=2),
  error('Requires two input arguments.');
else
  if (isstr(A) | isstr(b)),
    error('Requires one matrix and one vector as input arguments.');
  else
    [U,S,V]=svd(A);
    ub=U'*b;
    y=zeros(size(A,2),1);
%    for i=1:size(A,2),	% mod by pic, was size(A,2)
    for i=1:min(size(A)),	% mod by pic, was size(A,2)
      if (S(i,i)~=0),
	y(i)=ub(i)/S(i,i);
      else
	y(i)=1.0e+308;
      end;
    end;
    x=V*y;
  end;
end;

function  x = psinvsol(A,b);

% PSINVSOL Computes pseudo-inverse solution x of the system Ax=b.
% x = psinvsol(A,b);
%
% input  : Coeficient Matrix of the system, A
%			  Result vector of the system, b
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=2),
  error('Requires two input arguments.');
else
  if (isstr(A) | isstr(b)),
    error('Requires one matrix and one vector as input arguments.');
  else
    x=inv(A'*A)*A'*b;
  end;
end;

function  x = psinvsvd(A,b);

% PSINVSVD Computes pseudo-inverse solution x of the system Ax=b,
%   using the SVD of A.
% x = psinvsvd(A,b);
%
% input  : Coeficient Matrix of the system, A
%			  Result vector of the system, b
% output : Solution vector, x
%
% Nuno Alexandre Cid Martins
% Coimbra, Sep 29, 1998
% I.S.R.

if (nargin~=2),
  error('Requires two input arguments.');
else
  if (isstr(A) | isstr(b)),
    error('Requires one matrix and one vector as input arguments.');
  else
    [U,S,V]=svd(A);
    Sp=zeros(size(S));
    for i=1:size(S,2),
      if (S(i,i)~=0),
	Sp(i,i)=1/S(i,i);
      else
	Sp(i,i)=0;
      end;
    end;
    Ap=V*Sp'*U';
    x=Ap*b;
  end;
end;
