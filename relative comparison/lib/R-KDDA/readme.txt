**************************************************************************
* Matlab source codes for the kernel direct discriminant analysis (KDDA) *
* Author: Lu Juwei                                                       *
*      Bell Canada Multimedia Lab, Dept. of ECE, U. of Toronto           *
* Released in 03 September 2003                                          *
**************************************************************************

The matlab functions implement the methods presented in the paper [TNN_KDDA02.pdf]
    Juwei Lu, K.N. Plataniotis, and A.N. Venetsanopoulos, "Face Recognition Using 
    Kernel Direct Discriminant Analysis Algorithms", IEEE Transactions on Neural 
    Networks, Vol. 14, No. 1, Page: 117-126, January 2003.
and the chapter [JLu_KP_ANV.pdf] (An extension to the above TNN paper)
    Juwei Lu, K.N. Plataniotis and A.N. Venetsanopoulos, “Kernel Discriminant Learning 
    with Application to Face Recognition”, to appear, in “Support Vector Machines: 
    Theory and Applications”, Lipo WANG, Editors, Springer-Verlag, to be published in 
    2004.


[Usages:]
1. To find the KDDA based feature representation with RBF kernel,
    1.1. use function F_KDDA_RbfPro() to find the kernel discriminant subspace.
    1.2. use function F_KDDA_RbfPrj() to project the test samples into the kernel discriminant subspace.

2. To find the KDDA based feature representation with polynomial kernel,
    2.1. use function F_KDDA_PolyPro() to find the kernel discriminant subspace.
    2.2. use function F_KDDA_PolyPrj() to project the test samples into the kernel discriminant subspace.

[Note:]
In addition to the kernel function and its involved parameters, the regularization
parameter $eta$ in function F_KDDA_Rbf()/F_KDDA_Poly() does affect the classification 
performance. Try different values of these parameters to find the best one.

[Restrictions:]
In all documents and papers that report on research that uses the matlab codes, the researcher(s) must reference the following paper: 
    Juwei Lu, K.N. Plataniotis, and A.N. Venetsanopoulos, "Face Recognition Using 
    Kernel Direct Discriminant Analysis Algorithms", IEEE Transactions on Neural 
    Networks, Vol. 14, No. 1, Page: 117-126, January 2003.


Any comments and questions can be sent to juwei@dsp.utoronto.ca.
