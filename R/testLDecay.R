distance<-c(19,49,81,91,104,131,158,167,30,1000,20000,100,150,11,20,33) 
LD.data<-c(0.6,0.07,0.018,0.007,0,0.09,0.09,0.05,0,0.001,0,0.6,0.4,0.2,0.5,0.4)
n<-52

HW.st<-c(C=0.1)
HW.nonlinear <- nls(
    LD.data ~ ( (10+C*distance) / ((2+C*distance)*(11+C*distance)))*(1+((3+C*distance)*(12+12*C*distance+(C*distance)^2))/(n*(2+C*distance)*(11+C*distance))),
    start=HW.st,
    control=nls.control(maxiter=100)
    )
tt <- summary(HW.nonlinear)
new.rho <- tt$parameters[1]
fpoints <- ((10+new.rho*distance)/((2+new.rho*distance)*(11+new.rho*distance)))*(1+((3+new.rho*distance)*(12+12*new.rho*distance+(new.rho*distance)^2))/(n*(2+new.rho*distance)*(11+new.rho*distance)))

n <- 110
HW.st<-c(C=0.1)
HW.nonlinear <- with(ldList %>% filter(bp < 1e6),
                     nls(
                         LD ~ ( (10+C*bp) / ((2+C*bp)*(11+C*bp)))*(1+((3+C*bp)*(12+12*C*bp+(C*bp)^2))/(n*(2+C*bp)*(11+C*bp))),
                         start=HW.st,
                         control=nls.control(maxiter=100)
                     )
)
tt <- summary(HW.nonlinear)
new.rho <- tt$parameters[1]
ldList %>%
    mutate(hw = ((10+new.rho*bp)/((2+new.rho*bp)*(11+new.rho*bp)))*(1+((3+new.rho*bp)*(12+12*new.rho*bp+(new.rho*bp)^2))/(n*(2+new.rho*bp)*(11+new.rho*bp)))) %>%
    ggplot(aes(bp / 1e3)) +
    geom_point(aes(y = LD^2), alpha = 0.2) +
    geom_line(aes(y = hw), colour = "blue") +
    geom_vline(xintercept = 40, colour = "grey", linetype = 2) +
    geom_vline(xintercept = 100, colour = "grey", linetype = 2) +
    labs(x = "kb",
         y = expression(r^2)) +
    scale_x_continuous(breaks = c(seq(0, 1e3, by = 200), 40, 100),
                       expand = expand_scale(0.02)) +
    scale_y_continuous(expand = expand_scale(0.02))
