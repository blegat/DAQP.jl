struct QPj
  n::Cint
  m::Cint
  ms::Cint
  H::Matrix{Cdouble}
  f::Vector{Cdouble}
  A::Matrix{Cdouble}
  bupper::Vector{Cdouble}
  blower::Vector{Cdouble}
  sense::Vector{Cint}
  bin_ids::Vector{Cint}
  nb::Cint
end
function QPj() 
  return QPj(0,0,0,Matrix{Cdouble}(undef,0,0),Vector{Cdouble}(undef,0),Matrix{Cdouble}(undef,0,0), Vector{Cdouble}(undef,0), Vector{Cdouble}(undef,0), Vector{Cint}(undef,0),Vector{Cint}(undef,0),0)
end
function QPj(H::Matrix{Float64},f::Vector{Float64},
	A::Matrix{Float64},bupper::Vector{Float64}, blower::Vector{Float64},
	sense::Vector{Cint};A_rowmaj=false)
  # TODO: check consistency of dimensions
  if(A_rowmaj)
      (n,mA) = size(A);
  else
      (mA,n) = size(A);
  end
  m = length(bupper);
  ms = m-mA;
  bin_ids = findall(sense.&BINARY .!=0).-1;
  nb = length(bin_ids)
  if(!A_rowmaj)
      A = A' # Transpose A for col => row major
  end
  return QPj(n,m,ms,H,f,A,bupper,blower,sense,bin_ids,nb)
end

struct QPc 
  n::Cint
  m::Cint
  ms::Cint
  H::Ptr{Cdouble}
  f::Ptr{Cdouble}
  A::Ptr{Cdouble}
  bupper::Ptr{Cdouble}
  blower::Ptr{Cdouble}
  sense::Ptr{Cint}
  bin_ids::Ptr{Cint}
  nb::Cint
end
function QPc(qpj::QPj)
  return QPc(qpj.n,qpj.m,qpj.ms,
			 pointer(qpj.H),pointer(qpj.f),
             pointer(qpj.A),pointer(qpj.bupper),pointer(qpj.blower),pointer(qpj.sense),pointer(qpj.bin_ids),qpj.nb)
end

struct DAQPSettings
  primal_tol::Cdouble
  dual_tol::Cdouble
  zero_tol::Cdouble
  pivot_tol::Cdouble
  progress_tol::Cdouble

  cycle_tol::Cint
  iter_limit::Cint
  fval_bound::Cdouble

  eps_prox::Cdouble
  eta_prox::Cdouble

  rho_soft::Cdouble
end
function DAQPSettings()
  settings = Ref{DAQP.DAQPSettings}()
  ccall((:daqp_default_settings, libdaqp), Nothing,(Ref{DAQP.DAQPSettings},), settings)
  return settings[]
end

struct DAQPResult
  x::Ptr{Cdouble}
  lam::Ptr{Cdouble}
  fval::Cdouble
  soft_slack::Cdouble

  exitflag::Cint
  iter::Cint
  nodes::Cint
  solve_time::Cdouble
  setup_time::Cdouble
end

function DAQPResult(x::Vector{Float64},lam::Vector{Float64})
  return DAQPResult(pointer(x),pointer(lam),0,0,0,0,0,0,0)
end

struct Workspace
  qp::Ptr{QPc}
  n::Cint
  m::Cint
  ms::Cint
  M::Ptr{Cdouble}
  dupper::Ptr{Cdouble}
  dlower::Ptr{Cdouble}
  Rinv::Ptr{Cdouble}
  v::Ptr{Cdouble}
  sense::Ptr{Cint}
  scaling::Ptr{Cdouble}

  x::Ptr{Cdouble}
  xold::Ptr{Cdouble}

  lam::Ptr{Cdouble}
  lam_star::Ptr{Cdouble}

  u::Ptr{Cdouble}
  fval::Cdouble

  L::Ptr{Cdouble}
  D::Ptr{Cdouble}
  xldl::Ptr{Cdouble}
  zldl::Ptr{Cdouble}
  reuse_ind::Cint

  WS::Ptr{Cint}
  n_active::Cint

  iterations::Cint
  sing_ind::Cint

  soft_slack::Cdouble

  settings::Ptr{DAQPSettings}

  bnb::Ptr{Cvoid}
end
