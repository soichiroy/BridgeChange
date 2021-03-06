% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BridgeChangeReg.r
\name{BridgeChangeReg}
\alias{BridgeChangeReg}
\title{Bridge Regression with Change-point}
\usage{
BridgeChangeReg(
  y,
  X,
  n.break = 0,
  scale.data = TRUE,
  intercept = TRUE,
  mcmc = 100,
  burn = 100,
  verbose = 100,
  thin = 1,
  reduce.mcmc = NULL,
  c0 = 0.1,
  d0 = 0.1,
  nu.shape = 2,
  nu.rate = 2,
  known.alpha = FALSE,
  alpha.start = 1,
  alpha.limit = FALSE,
  alpha.MH = TRUE,
  beta.start = NULL,
  beta.alg = "BCK",
  Waic = FALSE,
  marginal = FALSE
)
}
\arguments{
\item{y}{Outcome vector.}

\item{X}{Design matrix. Columns correspond to variables.}

\item{n.break}{The number of change-point(s).
If \code{n.break = 0}, the model corresponds to the usual regression.
Default is \code{n.break = 0}.}

\item{scale.data}{If \code{TRUE}, \code{y} and \code{X} are both scaled to have zero mean and unit variance.
Default is \code{TRUE}.
We recommend \code{scale.data = TRUE} unless the original data are already scaled.}

\item{intercept}{A boolean. If \code{TRUE}, estimate intercept by MLE. The estimated intercept is used to detect breaks.
This option does not affect the result when \code{n.break = 0}.
We recommend \code{intercept = TRUE} when the number of break is not zero.}

\item{mcmc}{The number of iterations for gibbs updates. Default is 100.}

\item{burn}{The number of burn-in periods for gibbs updates. Default is 100.}

\item{verbose}{Iterations at which the results are printed on the console. Default is every 100th iteration.}

\item{thin}{Thinning for gibbs updates. Default is 1 (no thinning).}

\item{reduce.mcmc}{The number of reduced MCMC iterations for marginal likelihood computations.
If \code{reduce.mcmc = NULL}, \code{mcmc/thin} is used.}

\item{c0}{Scale parameter for Gamma distribution. Used for the prior of \eqn{\sigma^2}.
Default is 0.1.}

\item{d0}{Shape parameter for Gamma distribution. Used for the prior of \eqn{\sigma^2}.
Default is 0.1.}

\item{nu.shape}{Shape parameter for Gamma distribution. Used for the prior for \eqn{\tau}.
Default is 2.0.}

\item{nu.rate}{Rate parameter for Gamma distribution. Used for the prior for \eqn{\tau}.
Default is 2.0.}

\item{known.alpha}{If \code{TRUE}, a user must specify a numeric value \eqn{[0, 2]} in \code{alpha.start}.
Default is \code{FALSE} and therefore \eqn{\alpha} will be estimated.}

\item{alpha.start}{Starting value for alpha.
When \code{known.alpha = TRUE}, alpha is fixed to the value of this argument.
Default is 1.}

\item{alpha.limit}{If \code{TRUE}, alpha is sampled from \eqn{(0,1)}, otherwise alpha is sampled between \eqn{(0,2)}.
Default is \code{FALSE}.}

\item{alpha.MH}{If \code{TRUE}, alpha is updated by the Metropolis–Hastings algorithm.
If \code{FALSE} the Griddy gibbs sampler is used instead.
Default is \code{TRUE}.}

\item{beta.start}{Starting values of beta. If \code{NULL}, randomly choose beta.start from OLS or standard normal distribution.
Default is \code{NULL}.}

\item{beta.alg}{An algorithm to sample beta.
Default is \code{beta.alg = "BCK"}.
Also supported is the traditional sampler based on the Cholesky decomposition: \code{beta.alg = "CHL"}.}

\item{Waic}{If \code{TRUE}, WAIC is computed after the parameter estimation.
Default is \code{FALSE}.}

\item{marginal}{If \code{TRUE}, the marginal likelihood is computed based on Chib's method.
Default is \code{FALSE}.}
}
\value{
An mcmc object that contains the posterior sample of coefficients and variances as columns.
 Rows correspond to mcmc samples. This object can be summarized by functions provided by the coda package.
 The object contains an attribute \code{"intercept"} that stores mcmc samples for intercept and an attribute state storage matrix that contains posterior samples of hidden states.
}
\description{
Univariate response linear change-point model with Bridge prior.
}
\examples{
####################################
## no change
####################################

set.seed(1999)

## simulate data
K <- 100
n <- 100
X <- matrix(rnorm(n*K), n, K)
sig2 <- 0.2
beta.true <- matrix(rnorm(K), K, 1)*5
beta.true[sample(1:K, K/2, replace=FALSE)] <- 0
Y <- X\%*\%beta.true + rnorm(n, 0, sqrt(sig2))

## global parameter for estimation 
mcmc <- burn <- 100; thin <- 1; verbose <- 100;


## fit the model
out0 <- BridgeChangeReg(
    y = Y, X = X, n.break = 0,
    mcmc = mcmc, burn = burn,
    thin = thin, verbose = verbose
)

## obtain
beta.est <- coef(out0)

## plot
plot(beta.est, beta.true, ylab="TRUE", xlab="EST", type = "n",
       xlim = range(beta.est), ylim = range(beta.true), asp = 1)
abline(a=0, b=1, col="red", lty = 3, lwd = 1.5)
points(beta.est, beta.true, col="darkblue")

## summary of all results
## (show all coefficients and sigma estimates)
summary(out0)
plot(out0)


####################################
## change-point case
####################################

set.seed(1973);
## generate data
out <- BridgeChangeSim(
    ntime=100, predictor = 100,
    rho=0.0, constant.p =0,
    positive.jump=FALSE, varying.p = 0.5,
    break.point = 0.5, dgp.only=TRUE
)

## plot generated data
plot(1:length(out$true.beta[1,]), out$true.beta[1,],
    xlab="predictor", ylab="coefficients",
    ylim=range(out$true.beta), type='n')
points(out$true.beta[1,], col="red", pch="1", cex=1)
points(out$true.beta[2,], col="blue", pch="2", cex=1)

## fit he model
set.seed(11173);
out0 <- BridgeChangeReg(
    y = out$y.c, X = out$x.c, n.break = 0,
    scale.data=TRUE, intercept = TRUE,
    mcmc = mcmc, burn = burn, thin = thin, verbose = verbose,
    alpha.MH = TRUE, waic = TRUE
)

set.seed(11173);
out1 <- BridgeChangeReg(
    y = out$y.c, X = out$x.c, n.break = 1,
    scale.data = TRUE, intercept = TRUE,
    mcmc = mcmc, burn = burn, thin = thin, verbose = verbose,
    alpha.MH = TRUE, waic = TRUE
)


set.seed(11173);
out2 <- BridgeChangeReg(
    y=out$y.c, X=out$x.c, n.break = 2,
    scale.data = TRUE, intercept = TRUE,
    mcmc = mcmc, burn = burn, thin=thin, verbose=verbose,
    alpha.MH = TRUE, waic = TRUE
)

## model selection by WAIC
waic <- WaicCompare(list(out0, out1, out2), print = TRUE)

## plot state transitions 
par(mfrow = c(1,2))
MCMCpack::plotState(out1)
MCMCpack::plotState(out2)
}
