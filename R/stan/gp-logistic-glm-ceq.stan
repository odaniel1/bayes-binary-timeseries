functions {
  vector gp_f(real[] t, vector eta, real alpha, real rho, real delta){
    int N = size(t);
    vector[N] f;
    matrix[N, N] L_K;
    matrix[N, N] K = cov_exp_quad(t,alpha,rho);
    
    // diagonal elements
    for (n in 1:N)
      K[n, n] = K[n, n] + delta;
    
    L_K = cholesky_decompose(K);
    f = L_K * eta;
    
    return f;
  }
}
data {
  int<lower=1> N; // no. rows of data
  real time[N];   // time stamp  (at time n)
  int<lower=0> count[N]; // total samples (at time n)
  int<lower=0> succ[N];  // numberof successes  (at time n)
}
transformed data {
  real delta = 1e-9;
}
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real a;
  vector[N] eta;
}
model {
  vector[N] f;
  {
    matrix[N, N] L_K;
    matrix[N, N] K = cov_exp_quad(time,alpha,rho);
    
    // diagonal elements
    for (n in 1:N)
      K[n, n] = K[n, n] + delta;
    
    L_K = cholesky_decompose(K);
    f = L_K * eta;
  }
  
  rho ~ inv_gamma(5, 5);
  alpha ~  normal(0, 1);
  a ~ normal(0, 1);
  eta ~ normal(0, 1);
  
  succ ~ binomial_logit(count, a + f);
}
generated quantities {
  vector[N] p;
  p = inv_logit(a + gp_f(time, eta, alpha, rho, 1e-9));
}
