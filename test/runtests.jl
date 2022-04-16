using LinearAlgebra
using Random
using Test
using DAQP
include(joinpath(dirname(@__FILE__), "utils.jl"))

nQPs = 100;
n = 100; m = 500; ms = 50;
nAct = 80
kappa = 1e2
tol = 1e-4
		  	

@testset "Randomly generated feasible QPs (C )" begin
  for nQP in 1:nQPs
	xref,H,f,A,bupper,blower,sense = generate_test_QP(n,m,ms,nAct,kappa);
	x,fval,exitflag,info = DAQP.quadprog(H,f,A,bupper,blower,sense);
	@test norm(xref-x) < tol;
  end
end

@testset "Randomly generated feasible QPs (JL)" begin
  for nQP in 1:25
	xref,H,f,A,bupper,blower,sense = generate_test_QP(20,100,0,16,1e2);
	x,fval,exitflag,info = DAQP.daqp_jl(H,f,[A;-A],[bupper;-blower],[sense;sense],Int64[]);
	@test norm(xref-x) < tol;
  end
end
