/* --------------------------------------------------------------------------------- */
/* Task3-jackknide.SAS file */
/* This file has implementation of jackknife simpulation of seal body lengths.  */
/* As results the programme will display the mean of jackknife estimat, biased  */
/* and standard error of the mean.   */
/* --------------------------------------------------------------------------------- */

%web_drop_table(JK.DATA);

FILENAME REFFILE '/folders/myfolders/seals.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=JK.DATA;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=JK.DATA;
RUN;

%web_open_table(JK.DATA);

/*Creating the copy of the dataset*/
DATA JK.COPY_DATA;
SET JK.DATA;
RUN;

/*Creating the dataset with only 'lengths' variable*/
DATA JK.DATA_LENGTHS;
SET JK.COPY_DATA;
KEEP Lengths
RUN;

/*Numeric summary of the length variable*/
PROC UNIVARIATE DATA=JK.DATA_LENGTHS;
VAR Lengths;
RUN;
 
/* Convert length column into matrix */
proc iml;
use JK.DATA_LENGTHS;
read all var {"Lengths"} into lengthMatrix;
close;

/* Compute a statistic for original sample */
originalstatisticMean = mean(lengthMatrix);

print originalstatisticMean;

/* calculating the number of rows */
numberOfRows = nrow(lengthMatrix);

/* insilizatation of the matrix in which Jacknife samples can be stored */
outputMatrixOfJK = j(numberOfRows - 1, numberOfRows, 0);

/* to store the mean of each Jacknife sample */
outputMatrixOfJK_mean = j(numberOfRows, 1, 0);

/* loop to creating a Jacknife sample,  
and remove the i th observation from i th jackknife sample and 
compute a statistic mean for each and store it to a matrix */
do i = 1 to numberOfRows;
	outputMatrixOfJK[,i] = remove(lengthMatrix, i)`;  
	outputMatrixOfJK_mean[i] = mean(outputMatrixOfJK[,i]);
end;

print outputMatrixOfJK;

print outputMatrixOfJK_mean;

/* calculating the mean of each mean matrix of each jackknife sample */
meanJKestimate =  mean(outputMatrixOfJK_mean);

/* calculate jackknife bias */
jkBias = (numberOfRows-1)*(meanJKestimate -  originalstatisticMean);

/* calculate the standard error of the mean */
sampleSizeCalculation = (numberOfRows-1)/numberOfRows;
squareOfmeans = ssq(outputMatrixOfJK_mean  - meanJKestimate);
stdErrJack = sqrt(sampleSizeCalculation * squareOfmeans);

/* Printing the statistical summary of the results */
Statistical_summary = originalstatisticMean || meanJKestimate || jkBias || stdErrJack;
print Statistical_summary[c={"Estimate - original Sample " "Mean Jackknife Estimate" "Jackknife Bias" "Standard Error"}];
