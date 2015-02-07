#include "mex.h"
#include <iostream>
using namespace std;
/* The computational routine */
double f1 (double *l, double *c, int n){
	int pairSize = n*(n-1)/2;
	int *labelPair = new int [pairSize];
	int *clusterPair = new int [pairSize];
	int i;
	int j;
	int k = 0;
	for (i=0;i<pairSize;i++){
		labelPair[i] = 0;
		clusterPair[i] = 0;
	}
	for (i=0;i<n;i++)
		for (j=i+1;j<n;j++){
			if (l[i] == l[j])
				labelPair[k] = 1;
			if (c[i] == c[j])
				clusterPair[k] = 1;
			k++;
		}
	int correctSamePairSize = 0;
	int PredictSamePairSize = 0;
	int TrueSamePairSize = 0;
	for (i=0;i<pairSize;i++){
		if (labelPair [i] == 1)
			TrueSamePairSize++;
		if (clusterPair[i] == 1)
			PredictSamePairSize++;
		if ((clusterPair[i] == labelPair [i]) && (labelPair [i] == 1))
			correctSamePairSize++;}
	double precision = double(correctSamePairSize)/double(PredictSamePairSize);
	double recall = double(correctSamePairSize)/double(TrueSamePairSize);
    //return precision;
    delete labelPair;
    delete clusterPair;
	return 2*precision*recall/(precision+recall);
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *label;           
    double *clustering;            
    int n;                  
    double *fmeasure;
   
    /* get the value of the scalar input  */
    label = (mxGetPr(prhs[0]));

    /* create a pointer to the real data in the input matrix  */
    clustering = (mxGetPr(prhs[1]));

    /* get dimensions of the input matrix */
    n = mxGetN(prhs[0]);
    
    //plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);

    /* get a pointer to the real data in the output matrix */
    fmeasure = mxGetPr(plhs[0]);

    /* call the computational routine */
    *fmeasure = f1 (label,clustering,n);
}