# -*- coding: utf-8 -*-
"""
Created on Fri Feb 03 11:13:18 2017

@author: Ma'am Afzal
"""

import numpy as np

def sigmoid(x):
    return 1/(1+np.exp(-x)) 
def dsigmoid(y):
    return y * (1.0 - y)
def calc_meansqerror(real_val,val):
    # The error for each neuron is calculated by the Mean Square Error method:
    error = 0.5*np.square(real_val - val)
    return error
def pd_error_wrt_output(real_val,val):
    return -(real_val-val)  
    

    
def BGLCalcANN(opticald1,opticald2,opticald3,realbgl=0):
    accurate_bgl=realbgl
    #by default it is 0

    opdens1 = opticald1
    opdens2 = opticald2
    opdens3 = opticald3
    
    #weights
    w1 = np.array([[-.7200,-2.1339,-2.6487,-1.6305,-2.4648,-2.3817,0.9911,-2.4450,1.0575,-1.2526]])  
    w2 = np.array([-1.8341,1.6408,-1.0157,-2.2957,0.3102,-1.8592,2.0438,0.3549,2.9467,2.7371])
    w3 = np.array([2.0734,1.4818,1.0253,1.0672,-1.6974,0.2694,1.8781,-2.4238,0.0682,-1.0634])
    b = np.array([3.2548,2.1903,1.6855,0.9870,0.2725,-0.4620,1.1163,-1.1534,2.2939,-2.6764])
    epochs=600000
    learningrate=5
    if accurate_bgl==0:
        # Feed forward through layers 1, and 2
        x = (w1*opdens1 +w2*opdens2 +w3*opdens3) + b
        #print(sigmoid(x))
        bgl=sigmoid(x)
        #print(bgl)
        return np.array([bgl.mean()])
    else:  #if bgl given , back propagate
    
        for epoch in xrange(epochs):
             # Feed forward through layers 1, and 2
            x = (w1*opdens1 +w2*opdens2 +w3*opdens3) + b
            #print(sigmoid(x))
            bgl=sigmoid(x)
            #print(bgl)
            
        
    
        
            # how much did we miss the target value?
            
            #neurondeltas
            # ∂E/∂zⱼ
            # Determine how much the neuron's total input has to change to move closer to the expected output
            #
            # Now that we have the partial derivative of the error with respect to the output (∂E/∂yⱼ) and
            # the derivative of the output with respect to the total net input (dyⱼ/dzⱼ) we can calculate
            # the partial derivative of the error with respect to the total net input.
            # This value is also known as the delta (δ) [1]
            # δ = ∂E/∂zⱼ = ∂E/∂yⱼ * dyⱼ/dzⱼ
            pd_error_wrt_total_netinput=pd_error_wrt_output(accurate_bgl,bgl.mean())*dsigmoid(bgl.mean())
        
       
            #update neuron weights
            
            
            # ∂Eⱼ/∂wᵢⱼ = ∂E/∂zⱼ * ∂zⱼ/∂wᵢⱼ
            
             # The total net input is the weighted sum of all the inputs to the neuron and their respective weights:
            # = zⱼ = netⱼ = x₁w₁ + x₂w₂ ...
            #
            # The partial derivative of the total net input with respective to a given weight (with everything else held constant) then is:
            # = ∂zⱼ/∂wᵢ = some constant + 1 * xᵢw₁^(1-0) + some constant ... = xᵢ ie input itself for w1
            
            #w1
            pd_error_wrt_weight1=pd_error_wrt_total_netinput *opdens1
            w1-=learningrate*pd_error_wrt_weight1
        
        
            #w2
         
            pd_error_wrt_weight2=pd_error_wrt_total_netinput *opdens2
            w2-=learningrate*pd_error_wrt_weight2
        
        
            #w3
            pd_error_wrt_weight3=pd_error_wrt_total_netinput *opdens3
            w3-=learningrate*pd_error_wrt_weight3
       
        
            if (epoch% 10000) == 0:
                print "E-rror:" + str(np.mean(np.abs(calc_meansqerror(accurate_bgl,bgl.mean()))))
                
                
                
        return np.array([bgl.mean(),np.mean(np.abs(calc_meansqerror(accurate_bgl,bgl.mean())))])
        

        
#BGLCalcANN(2.03,4.09,3.09,170)
        
        