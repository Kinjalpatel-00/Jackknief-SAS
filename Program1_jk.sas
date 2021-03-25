proc iml;

start JackSampMat(x); 
   n = nrow(x);
   B = j(n-1, n,0);
   do i = 1 to n;
      B[,i] = remove(x, i)`;   
   end;
   return B;
finish;

start EvalStatMat(x); 
   return std(x);   
finish;


x = {58,67,74,74,80,89,95,97,98,107};
 
T = EvalStatMat(x);    

T_LOO = EvalStatMat( JackSampMat(x) ); 

T_Avg = mean( T_LOO` );              


biasJack = (n-1)* (T_Avg - T);

stdErrJack = sqrt( ((n-1)/n) * (ssq(T_LOO - T_Avg)) );
result = T || T_Avg || biasJack || stdErrJack;
print result[c={"Estimate" "Mean Jackknife Estimate" "Bias" "Std Error"}];

