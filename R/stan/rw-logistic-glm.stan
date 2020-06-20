data {
  int<lower=0> N;
  real<lower=0> time[N];
  int count[N];
  int succ[N];
}
parameters {
  real a;
  real<lower=0> rw_sd;
  real rw_step[N-1];
}
transformed parameters{
  real pi[N];

  pi[1] = a;
  for(n in 2:N){ 
    pi[n] = pi[n-1] + rw_step[n-1] * rw_sd * sqrt(time[n] - time[n-1]);
  }
}
model {
  a ~ std_normal();
  rw_step ~ std_normal();
  rw_sd ~ exponential(1);
  succ ~ binomial_logit(count, pi);
}
generated quantities{
  real<lower=0,upper=1> p[N];
  p = inv_logit(pi);
}
